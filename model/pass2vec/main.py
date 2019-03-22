"""
Pass2Vec model application
Encode sequence of passes

Usage :
python -m model.pass2vec.main <pass_data_file.csv>

Wildcard:
-s input for saving file

"""
import argparse
import pandas
from model.pass2vec.src.SequenceFactory import SequencesFactory
from keras.models import load_model


def model_application(model, data):
    """
    Return Expected goal for every shot
    """
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    processed_data = sequences_factory.build_data(sequences, save_img=False)
    processed_data = processed_data.astype('float32') / 255.
    encoded_img = model.predict(processed_data)

    sequences_informations = sequences_factory.get_metadata(sequences)
    header = [f"f_{i}" for i in range(0, encoded_img.shape[1])]
    encoded_pass = pandas.DataFrame(data=encoded_img, columns=header)
    return pandas.concat((sequences_informations, encoded_pass), axis=1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing passes data")
    parser.add_argument("-s", "--save", help="input for saving file", action="store_true")
    args = parser.parse_args()

    model = load_model('mlruns/0/b3df150e2f0b46d0b5ca91fc103c3a34/artifacts/encoder_model/model.h5')
    pass_data = pandas.read_csv(args.data).dropna(axis=0).head(10000)
    encoded_passes = model_application(model, pass_data)

    # Saving option
    if args.save:
            file_path = input("File path (for example /Users/username/folder/file.csv): ")
            encoded_passes.to_csv(file_path, index=False)


