#!/usr/bin/env python3

import argparse
import csv
import json
import os
import sys
from pathlib import Path
import re

def parse_crispresso_quantification(quantification_file):
    """Parse CRISPResso quantification file to extract key editing metrics"""
    results = {}
    try:
        with open(quantification_file, 'r') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                results = {
                    'amplicon': row['Amplicon'],
                    'unmodified_percent': float(row['Unmodified%']),
                    'modified_percent': float(row['Modified%']),
                    'reads_input': int(row['Reads_in_input']),
                    'reads_aligned_all': int(row['Reads_aligned_all_amplicons']),
                    'reads_aligned': int(row['Reads_aligned']),
                    'reads_unmodified': int(row['Unmodified']),
                    'reads_modified': int(row['Modified']),
                    'reads_discarded': int(row['Discarded']),
                    'insertions': int(row['Insertions']),
                    'deletions': int(row['Deletions']),
                    'substitutions': int(row['Substitutions']),
                    'only_insertions': int(row['Only Insertions']),
                    'only_deletions': int(row['Only Deletions']),
                    'only_substitutions': int(row['Only Substitutions']),
                    'insertions_deletions': int(row['Insertions and Deletions']),
                    'insertions_substitutions': int(row['Insertions and Substitutions']),
                    'deletions_substitutions': int(row['Deletions and Substitutions']),
                    'all_modifications': int(row['Insertions Deletions and Substitutions'])
                }
                break  # Take first amplicon
    except Exception as e:
        print(f"Error parsing quantification file: {e}")
        results = {}
    
    return results

def parse_mapping_statistics(mapping_file):
    """Parse CRISPResso mapping statistics"""
    mapping_stats = {}
    try:
        with open(mapping_file, 'r') as f:
            lines = f.readlines()
            if len(lines) >= 2:
                header = lines[0].strip().split('\t')
                data = lines[1].strip().split('\t')
                
                # Create mapping dict with proper names
                for i, col_name in enumerate(header):
                    if i < len(data):
                        try:
                            mapping_stats[col_name.lower().replace(' ', '_')] = int(data[i])
                        except ValueError:
                            mapping_stats[col_name.lower().replace(' ', '_')] = data[i]
                
                # Also add some standard field names for consistency
                if 'reads_in_input' in mapping_stats:
                    mapping_stats['reads_input'] = mapping_stats['reads_in_input']
                if 'reads_after_preprocessing' in mapping_stats:
                    mapping_stats['reads_aligned_all'] = mapping_stats['reads_after_preprocessing']
                    
    except Exception as e:
        print(f"Error parsing mapping statistics: {e}")
    
    return mapping_stats

def parse_indel_histogram(indel_file):
    """Parse indel histogram to get size distribution"""
    indel_sizes = {}
    try:
        with open(indel_file, 'r') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                size = int(row['indel_size']) if 'indel_size' in row else int(row['del_size'])
                freq = int(row['fq'])
                indel_sizes[size] = freq
    except Exception as e:
        print(f"Error parsing indel histogram: {e}")
    
    return indel_sizes

def parse_fastqc_data(fastqc_zip):
    """Extract basic FastQC statistics"""
    import zipfile
    
    fastqc_data = {}
    try:
        with zipfile.ZipFile(fastqc_zip, 'r') as zip_ref:
            # Find fastqc_data.txt file
            for file_name in zip_ref.namelist():
                if file_name.endswith('fastqc_data.txt'):
                    with zip_ref.open(file_name) as f:
                        content = f.read().decode('utf-8')
                        
                        # Parse basic statistics
                        basic_stats = {}
                        in_basic_stats = False
                        for line in content.split('\n'):
                            if line.startswith('>>Basic Statistics'):
                                in_basic_stats = True
                                continue
                            elif line.startswith('>>END_MODULE'):
                                in_basic_stats = False
                                continue
                            elif in_basic_stats and line.strip():
                                parts = line.split('\t')
                                if len(parts) >= 2:
                                    key = parts[0].strip()
                                    value = parts[1].strip()
                                    basic_stats[key] = value
                        
                        fastqc_data = {
                            'total_sequences': basic_stats.get('Total Sequences', 'N/A'),
                            'sequence_length': basic_stats.get('Sequence length', 'N/A'),
                            'percent_gc': basic_stats.get('%GC', 'N/A')
                        }
                    break
    except Exception as e:
        print(f"Error parsing FastQC data: {e}")
        fastqc_data = {
            'total_sequences': 'N/A',
            'sequence_length': 'N/A', 
            'percent_gc': 'N/A'
        }
    
    return fastqc_data

def create_summary_csv(sample_id, crispresso_results, fastqc_data, amplicon_seq, guide_seq, output_file):
    """Create a summary CSV with key metrics"""
    
    # Calculate additional metrics
    total_reads = crispresso_results.get('reads_input', 0)
    aligned_reads = crispresso_results.get('reads_aligned', 0)
    mapped_reads_all = crispresso_results.get('reads_aligned_all', 0)
    
    # Calculate mapping percentages
    mapping_rate = (aligned_reads / total_reads * 100) if total_reads > 0 else 0
    mapping_rate_all = (mapped_reads_all / total_reads * 100) if total_reads > 0 else 0
    
    # Editing efficiency
    editing_efficiency = crispresso_results.get('modified_percent', 0)
    
    # Indel calculations
    total_insertions = crispresso_results.get('insertions', 0)
    total_deletions = crispresso_results.get('deletions', 0)
    total_indels = total_insertions + total_deletions
    indel_percentage = (total_indels / total_reads * 100) if total_reads > 0 else 0
    
    # Reference reads (unmodified)
    reference_reads = crispresso_results.get('reads_unmodified', 0)
    reference_percentage = (reference_reads / aligned_reads * 100) if aligned_reads > 0 else 0
    
    summary_data = {
        'sample_id': sample_id,
        'amplicon_sequence': amplicon_seq,
        'amplicon_length': len(amplicon_seq) if amplicon_seq else 0,
        'guide_sequence': guide_seq if guide_seq and guide_seq != 'null' else 'N/A',
        'guide_length': len(guide_seq) if guide_seq and guide_seq != 'null' else 0,
        'total_read_count': total_reads,
        'mapped_read_count': aligned_reads,
        'mapped_read_count_all_amplicons': mapped_reads_all,
        'mapping_percentage': round(mapping_rate, 2),
        'mapping_percentage_all_amplicons': round(mapping_rate_all, 2),
        'reads_mapped_to_reference': reference_reads,
        'reference_mapping_percentage': round(reference_percentage, 2),
        'editing_efficiency_percent': round(editing_efficiency, 2),
        'total_indels': total_indels,
        'insertion_count': total_insertions,
        'deletion_count': total_deletions,
        'indel_percentage': round(indel_percentage, 2),
        'unmodified_reads': crispresso_results.get('reads_unmodified', 0),
        'modified_reads': crispresso_results.get('reads_modified', 0),
        'reads_with_insertions': crispresso_results.get('insertions', 0),
        'reads_with_deletions': crispresso_results.get('deletions', 0),
        'reads_with_substitutions': crispresso_results.get('substitutions', 0),
        'only_insertions': crispresso_results.get('only_insertions', 0),
        'only_deletions': crispresso_results.get('only_deletions', 0),
        'only_substitutions': crispresso_results.get('only_substitutions', 0),
        'mixed_modifications': crispresso_results.get('all_modifications', 0),
        'reads_discarded': crispresso_results.get('reads_discarded', 0),
        'most_frequent_indel_size': crispresso_results.get('most_frequent_indel_size', 'N/A'),
        'most_frequent_indel_count': crispresso_results.get('most_frequent_indel_count', 0),
        'total_indel_events': crispresso_results.get('total_indel_events', 0),
        'unique_indel_sizes': crispresso_results.get('unique_indel_sizes', 0),
        'fastqc_total_sequences': fastqc_data.get('total_sequences', 'N/A'),
        'fastqc_sequence_length': fastqc_data.get('sequence_length', 'N/A'),
        'fastqc_percent_gc': fastqc_data.get('percent_gc', 'N/A')
    }
    
    # Write summary CSV
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = summary_data.keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerow(summary_data)

def create_reference_info_csv(sample_id, amplicon_seq, guide_seq, output_file):
    """Create a reference info CSV with amplicon and guide sequences"""
    
    reference_data = {
        'sample_id': sample_id,
        'amplicon_sequence': amplicon_seq,
        'amplicon_length': len(amplicon_seq) if amplicon_seq else 0,
        'guide_sequence': guide_seq if guide_seq and guide_seq != 'null' else 'N/A',
        'guide_length': len(guide_seq) if guide_seq and guide_seq != 'null' else 0,
        'amplicon_gc_content': round((amplicon_seq.upper().count('G') + amplicon_seq.upper().count('C')) / len(amplicon_seq) * 100, 2) if amplicon_seq else 0,
        'guide_gc_content': round((guide_seq.upper().count('G') + guide_seq.upper().count('C')) / len(guide_seq) * 100, 2) if guide_seq and guide_seq != 'null' else 'N/A'
    }
    
    # Write reference info CSV
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = reference_data.keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerow(reference_data)

def create_detailed_csv(sample_id, crispresso_dir, output_file):
    """Create detailed CSV with position-specific modification data"""
    
    detailed_data = []
    
    # Try to read modification count vectors
    mod_count_file = os.path.join(crispresso_dir, 'Modification_count_vectors.txt')
    if os.path.exists(mod_count_file):
        try:
            with open(mod_count_file, 'r') as f:
                lines = f.readlines()
                
                if len(lines) >= 7:  # Expected format
                    # Parse the data
                    positions = list(range(1, len(lines[1].split('\t')))) # Position numbers
                    insertions = lines[1].strip().split('\t')[1:]  # Skip header
                    deletions = lines[2].strip().split('\t')[1:]
                    substitutions = lines[3].strip().split('\t')[1:]
                    all_mods = lines[4].strip().split('\t')[1:]
                    total_reads = lines[5].strip().split('\t')[1:]
                    
                    for i, pos in enumerate(positions):
                        if i < len(insertions) and i < len(deletions) and i < len(substitutions):
                            detailed_data.append({
                                'sample_id': sample_id,
                                'position': pos,
                                'insertions': float(insertions[i]) if insertions[i] != '' else 0,
                                'deletions': float(deletions[i]) if deletions[i] != '' else 0,
                                'substitutions': float(substitutions[i]) if substitutions[i] != '' else 0,
                                'total_modifications': float(all_mods[i]) if i < len(all_mods) and all_mods[i] != '' else 0,
                                'total_reads': float(total_reads[i]) if i < len(total_reads) and total_reads[i] != '' else 0
                            })
        except Exception as e:
            print(f"Error reading modification count vectors: {e}")
    
    # Write detailed CSV
    if detailed_data:
        with open(output_file, 'w', newline='') as csvfile:
            fieldnames = detailed_data[0].keys()
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(detailed_data)
    else:
        # Create empty file with headers
        with open(output_file, 'w', newline='') as csvfile:
            fieldnames = ['sample_id', 'position', 'insertions', 'deletions', 'substitutions', 'total_modifications', 'total_reads']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()

def main():
    parser = argparse.ArgumentParser(description='Create CSV summaries from CRISPResso2 results')
    parser.add_argument('--crispresso_dir', required=True, help='CRISPResso2 output directory')
    parser.add_argument('--fastqc_zip', help='FastQC ZIP file')
    parser.add_argument('--sample_id', required=True, help='Sample identifier')
    parser.add_argument('--amplicon_seq', required=True, help='Amplicon sequence')
    parser.add_argument('--guide_seq', help='Guide RNA sequence')
    parser.add_argument('--output_prefix', required=True, help='Output file prefix')
    
    args = parser.parse_args()
    
    # Find CRISPResso output subdirectory
    crispresso_subdir = None
    if os.path.isdir(args.crispresso_dir):
        # Look for CRISPResso_on_* subdirectory
        for item in os.listdir(args.crispresso_dir):
            item_path = os.path.join(args.crispresso_dir, item)
            if os.path.isdir(item_path) and item.startswith('CRISPResso_on_'):
                crispresso_subdir = item_path
                break
        
        # If no subdirectory found, use the directory itself
        if crispresso_subdir is None:
            crispresso_subdir = args.crispresso_dir
    else:
        print(f"Error: CRISPResso directory not found: {args.crispresso_dir}")
        sys.exit(1)
    
    # Parse CRISPResso results
    quantification_file = os.path.join(crispresso_subdir, 'CRISPResso_quantification_of_editing_frequency.txt')
    mapping_file = os.path.join(crispresso_subdir, 'CRISPResso_mapping_statistics.txt')
    
    crispresso_results = {}
    if os.path.exists(quantification_file):
        crispresso_results = parse_crispresso_quantification(quantification_file)
    
    if os.path.exists(mapping_file):
        mapping_stats = parse_mapping_statistics(mapping_file)
        crispresso_results.update(mapping_stats)
    
    # Parse FastQC data
    fastqc_data = {}
    if args.fastqc_zip and os.path.exists(args.fastqc_zip):
        fastqc_data = parse_fastqc_data(args.fastqc_zip)
    
    # Parse indel histogram for additional metrics
    indel_file = os.path.join(crispresso_subdir, 'Indel_histogram.txt')
    indel_stats = {}
    if os.path.exists(indel_file):
        indel_distribution = parse_indel_histogram(indel_file)
        if indel_distribution:
            # Calculate common indel size statistics
            total_indel_events = sum(indel_distribution.values())
            if total_indel_events > 0:
                # Most frequent indel size
                most_frequent_size = max(indel_distribution, key=indel_distribution.get)
                indel_stats = {
                    'most_frequent_indel_size': most_frequent_size,
                    'most_frequent_indel_count': indel_distribution[most_frequent_size],
                    'total_indel_events': total_indel_events,
                    'unique_indel_sizes': len(indel_distribution)
                }
    
    # Merge indel stats into crispresso results
    crispresso_results.update(indel_stats)
    
    # Create output files
    summary_file = f"{args.output_prefix}_summary.csv"
    detailed_file = f"{args.output_prefix}_detailed_results.csv"
    reference_file = f"{args.output_prefix}_reference_info.csv"
    
    create_summary_csv(args.sample_id, crispresso_results, fastqc_data, 
                      args.amplicon_seq, args.guide_seq, summary_file)
    
    create_detailed_csv(args.sample_id, crispresso_subdir, detailed_file)
    
    create_reference_info_csv(args.sample_id, args.amplicon_seq, args.guide_seq, reference_file)
    
    print(f"Results summary created: {summary_file}")
    print(f"Detailed results created: {detailed_file}")
    print(f"Reference info created: {reference_file}")

if __name__ == '__main__':
    main()
