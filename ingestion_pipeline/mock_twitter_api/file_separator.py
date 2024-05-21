import csv
import os

dataset_size = 1_600_000
total_files = 200

def split_csv(input_file, output_directory):
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    lines_per_file = dataset_size // total_files

    with open(input_file, 'r', encoding='latin-1') as csvfile:
        reader = csv.reader(csvfile)
        current_file_index = 1
        current_line_index = 0
        current_output_file = None


        for row in reader:
            if current_line_index % lines_per_file == 0:
                if current_output_file:
                    current_output_file.close()
                output_filename = os.path.join(output_directory, f"data_{current_file_index}.csv")
                current_output_file = open(output_filename, 'w', encoding='latin-1')
                writer = csv.writer(current_output_file, quoting=csv.QUOTE_ALL)
                current_file_index += 1
            writer.writerow(row)
            current_line_index += 1

        if current_output_file:
            current_output_file.close()

if __name__ == '__main__':
    split_csv('data/training.1600000.processed.noemoticon.csv', 'data/splitted/')
