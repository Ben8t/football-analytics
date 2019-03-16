import pandas
import numpy
from model.pass2vec.src.SequenceFactory import SequencesFactory
# from keras.models import Sequential
# from keras.layers import Flatten, Dense
# from sklearn.manifold import TSNE


if __name__ == "__main__":
    data = pandas.read_csv("model/pass2vec/resources/raw_passes.csv").head(100000).dropna(axis=0)
    print(data.shape)
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    result = sequences_factory.build_data(sequences)
    print(len(result))
    print(numpy.array(result).shape)
    # training_data = sequences_factory.build_data(sequences, 2, 2)
    # # training_data.to_csv("test.csv", index=False)
    # data_embedded = TSNE(n_components=2).fit_transform(training_data.drop(["game_id", "team_id", "sequence_length"], axis=1).dropna(axis=0))
    # result = pandas.concat((training_data, pandas.DataFrame(data_embedded, columns=["c1", "c2"])), axis=1)
    # result.to_csv("result_tsne.csv", index=False)
