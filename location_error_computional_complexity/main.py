import argparse
from location_error_computional_complexity.data import loader

classification_results = f'resources/location_error_prediction_CLASSIFICATION_20211004_230611_main'
regression_results = f'resources/location_error_prediction_REGRESSION_20211004_230611_main'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--classification", type=str, help='Absolute path to classification directory')
    parser.add_argument("--regression", type=str, help='Absolute path to regression directory')
    opt = parser.parse_args()

    # if opt.regression is not None:
    #     loader.build_stat(opt.regression)
    #
    # if opt.classification is not None:
    #     loader.build_stat(opt.classification)

    loader.build_stat(regression_results)