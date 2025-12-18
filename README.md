# Location Error Computational Complexity: Metadata Extractor

This utility script extracts file system metadata—specifically creation, modification, and last-access timestamps—from log files and final result reports.

The script performs a recursive traversal of a target directory to identify `log.txt` files and summary PDFs. It gathers timing statistics for these files to help analyze the duration and sequence of computational tasks.

To execute the extraction, run the [`extractor.sh`](https://www.google.com/search?q=extractor.sh) script and provide the path to the directory containing your results.

```shell
./extractor.sh <path_to_directory>
```

### Example

```shell
./extractor.sh ./resources/location_error_prediction_CLASSIFICATION_20211004_230611_main
```

Upon completion, the script generates a file named `log_statistic.csv` within the targeted directory. This CSV contains the compiled timestamps for all identified log and summary files.
