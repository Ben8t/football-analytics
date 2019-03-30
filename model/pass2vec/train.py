"""train.py
Train and save model
"""

import argparse
import pandas
import numpy
from model.pass2vec.src.SequenceFactory import SequencesFactory
from keras.layers import Input, Dense
from keras.models import Model
import mlflow
import mlflow.keras
import cv2

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--split_dataset_rate", default=0.3, type=float)
    parser.add_argument("--encoding_dim", default=256, type=int)
    parser.add_argument("--epochs", default=10, type=int)
    parser.add_argument("--batch_size", default=256, type=int)
    args = parser.parse_args()
    
    data = pandas.read_csv("model/pass2vec/resources/raw_passes.csv").head(100000).dropna(axis=0)
    print("Data loaded.")
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    result = sequences_factory.build_data(sequences, save_img=True)
    print("Sequences processed.")

    x_train = result[:int(args.split_dataset_rate * result.shape[0])]
    x_test = result[int(args.split_dataset_rate * result.shape[0]):]
    x_train = x_train.astype('float32') / 255.
    x_test = x_test.astype('float32') / 255.

    with mlflow.start_run(run_name="pass2vec_encoder"):
        input_img = Input(shape=(105*68,))
        
        encoded = Dense(args.encoding_dim, activation='relu')(input_img)
        decoded = Dense(105*68, activation='sigmoid')(encoded)
        
        autoencoder = Model(input_img, decoded)
        
        encoder = Model(input_img, encoded)
        encoded_input = Input(shape=(args.encoding_dim,))
        
        decoder_layer = autoencoder.layers[-1]
        decoder = Model(encoded_input, decoder_layer(encoded_input))

        autoencoder.compile(optimizer='adadelta', loss='binary_crossentropy')

        history = autoencoder.fit(x_train, x_train,
                    epochs=args.epochs,
                    batch_size=args.batch_size,
                    shuffle=True,
                    validation_data=(x_test, x_test))

        mlflow.log_param("split_dataset_rate", args.split_dataset_rate)
        mlflow.log_param("epochs", args.epochs)
        mlflow.log_param("encoding_dim", args.encoding_dim)
        mlflow.log_param("batch_size", args.batch_size)
        mlflow.log_metric("loss", history.history["loss"][-1])
        mlflow.log_metric("val_loss", history.history["val_loss"][-1])
        mlflow.keras.log_model(encoder, "encoder_model")
        mlflow.keras.log_model(decoder, "decoder_model")
