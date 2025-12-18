import os
from pathlib import Path
import re
import pandas as pd

regression_results = 'resources/location_error_prediction_REGRESSION_20211004_230611_main'
prediction_results = 'resources/location_prediction_20210928_125433'


def build_stat(root_directory):
    if os.path.exists(root_directory):
        print(f"Directory {root_directory} does not exist")

    stat_df = walk_directory_and_build_stat(root_directory)

    stat_df.to_csv(f'{root_directory}/log_statistic.csv', index=False)


# def unzip_archive(classification_directory):
#     zip_path = f'{resources}/Archive.zip'
#     extract_to = f'{resources}/'
#
#     if os.path.exists(classification_directory):
#         print("Files are already unzipped")
#     else:
#         with zipfile.ZipFile(zip_path, 'r') as zip_ref:
#             zip_ref.extractall(extract_to)
#         print("Unzipped successfully")


def file_stats(txt_path):
    permutation, building, floor = building_stat(txt_path)

    txt_target = Path(txt_path)
    pdf_target = Path(txt_path.replace('log.txt', 'results_summary.pdf'))

    txt_mtime = txt_target.stat().st_mtime
    txt_atime = txt_target.stat().st_atime
    txt_ctime = txt_target.stat().st_ctime

    pdf_mtime = pdf_target.stat().st_mtime
    pdf_atime = pdf_target.stat().st_atime
    pdf_ctime = pdf_target.stat().st_ctime

    stats = pd.DataFrame(data={
        'permutation': [permutation],
        'building': [building],
        'floor': [floor],
        'txt_ctime': [txt_ctime],
        'txt_mtime': [txt_mtime],
        'txt_atime': [txt_atime],
        'pdf_ctime': [pdf_ctime],
        'pdf_mtime': [pdf_mtime],
        'pdf_atime': [pdf_atime]
    })

    return stats


def building_stat(path):
    match = re.search(r'perm_(\d+)_bld_(\d+)_floor_(\d+)_log\.txt$', path)
    permutation, building, floor = match.groups()

    return permutation, building, floor


def walk_directory_and_build_stat(root_directory):
    directories = next(os.walk(root_directory), (None, None, []))[1]
    directory_stats = list(map(lambda directory: walk_directory_and_build_stat(f'{root_directory}/{directory}'), directories))
    filenames = next(os.walk(root_directory), (None, None, []))[2]  # [] if no file
    txt_filenames = [filename for filename in filenames if ".txt" in filename]
    stats = list(map(lambda filename: file_stats(f'{root_directory}/{filename}'), txt_filenames))
    results = pd.concat(stats + directory_stats, ignore_index=True)
    return results
