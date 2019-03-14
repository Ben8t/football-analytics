import pandas
import numpy
from model.pass2vec.src.SequenceFactory import SequencesFactory
from keras.models import Sequential
from keras.layers import Flatten, Dense


if __name__ == "__main__":
    data = pandas.read_csv("model/pass2vec/resources/raw_passes.csv").head(100000)
    print(data.shape)
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    training_data = sequences_factory.build_data(sequences, 3, 6)
    # training_data.to_csv("test.csv", index=False)
    