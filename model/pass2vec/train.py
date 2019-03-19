import pandas
import numpy
from model.pass2vec.src.SequenceFactory import SequencesFactory
# from keras.models import Sequential
# from keras.layers import Flatten, Dense
# from sklearn.manifold import TSNE
from keras.layers import Input, Dense
from keras.models import Model


if __name__ == "__main__":
    data = pandas.read_csv("model/pass2vec/resources/raw_passes.csv").head(10000).dropna(axis=0)
    print(data.shape)
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    result = sequences_factory.build_data(sequences, save_img=False)
    print(result.shape)

    split_rate = 0.3
    x_train = result[:int(split_rate * result.shape[0])]
    x_test = result[int(split_rate * result.shape[0]):]
    x_train = x_train.astype('float32') / 255.
    x_test = x_test.astype('float32') / 255.

    x_test_id = [sequence.id for sequence in sequences[int(split_rate * result.shape[0]):]]

    encoding_dim = 32

    input_img = Input(shape=(16384,))

    encoded = Dense(encoding_dim, activation='relu')(input_img)
    decoded = Dense(16384, activation='sigmoid')(encoded)
    autoencoder = Model(input_img, decoded)

    encoder = Model(input_img, encoded)

    encoded_input = Input(shape=(encoding_dim,))
    decoder_layer = autoencoder.layers[-1]
    decoder = Model(encoded_input, decoder_layer(encoded_input))

    autoencoder.compile(optimizer='adadelta', loss='binary_crossentropy')

    autoencoder.fit(x_train, x_train,
                epochs=100,
                batch_size=32,
                shuffle=True,
                validation_data=(x_test, x_test))
