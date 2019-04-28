"""
Pass2Vec model application
Encode sequence of passes

Usage :
python -m model.pass2vec.main <pass_data_file.csv>

Wildcard:
-s input for saving file
-d saving decoded images
"""
import argparse
import numpy
import pandas
import cv2
import logging
from model.pass2vec.src.SequenceFactory import SequencesFactory
from keras.models import load_model
# from sklearn.manifold import TSNE
from MulticoreTSNE import MulticoreTSNE as TSNE


def load_models(mlrun_id):
    """Load encoder and decoder models

    Args:
        mlrun_id (string): mlflow run id

    Returns:
        Encoder and decoder models
    """
    encoder_model = load_model(f"mlruns/0/{mlrun_id}/artifacts/encoder_model/model.h5")
    decoder_model = load_model(f"mlruns/0/{mlrun_id}/artifacts/decoder_model/model.h5")
    return encoder_model, decoder_model

def vec_to_img(vector, id=0, width=68, height=105, img_folder="model/pass2vec/resources"):
    """Rebuild image from decoded embeded data
    Utils function to test if the model did well

    Args:
        vector: (numpy array) decoded flatten image
        id: (int) an id for file saving
        width: (int) width to rebuild
        height: (int) height to rebuild
        img_folder: (string) path to save image

    Returns:
        if needed the image as a numpy array.
    """
    img_data = vector.reshape(width, height)
    norm_image = cv2.normalize(img_data, None, alpha = 0, beta = 255, norm_type = cv2.NORM_MINMAX, dtype = cv2.CV_32F)
    norm_image.astype(numpy.uint8)
    cv2.imwrite(f"{img_folder}/seq_decoded_{id}.png", norm_image)
    return norm_image

def model_application(encoder_model, decoder_model, data, decoding=False):
    """Return Expected goal for every shot

    Args:
        models (dict): encoder and decoder models.
        data (pandas.DataFrame): passes data.
        decoding (boolean): (optional) decoding encoded images to see if models did well.
    """
    sequences_factory = SequencesFactory()
    pass_list = sequences_factory.build_pass_list(data)
    sequences = sequences_factory.build_sequences(pass_list)
    sequences_informations = sequences_factory.get_metadata(sequences)
    processed_data = sequences_factory.build_data(sequences, save_img=False)

    processed_data = processed_data.astype('float32') / 255.
    encoded_img = encoder_model.predict(processed_data)

    if decoding:
        for id, img, sequence in zip(sequences_informations["id"], encoded_img, sequences):
            vec_to_img(decoder_model.predict(numpy.array([img])), id)
            sequence.to_vec(True)

    logging.info("TSNE computing...")
    tsne_result = TSNE(n_jobs=4, n_components=2, perplexity=30, n_iter=2000, random_state=8).fit_transform(encoded_img)

    header = [f"f_{i}" for i in range(0, encoded_img.shape[1])]
    encoded_pass = pandas.DataFrame(data=encoded_img, columns=header)
    tsne_pass = pandas.DataFrame(data=tsne_result, columns=["t1", "t2"])
    return pandas.concat((sequences_informations, encoded_pass, tsne_pass), axis=1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing passes data")
    parser.add_argument("-d", "--decoding", help="saving decoded images.", action="store_true", default=False)
    parser.add_argument("-s", "--save_file_path", help="file path to save data", default="model/pass2vec/resources/encoded_data.csv")
    args = parser.parse_args()

    logging.getLogger().setLevel(logging.INFO)

    
    logging.info("Loading data")
    pass_data = pandas.read_csv(args.data).dropna(axis=0).head(10000)
    encoder_model, decoder_model = load_models("c344bdd35a7249b980fea83c5a0c5535")
    encoded_passes = model_application(encoder_model , decoder_model, pass_data, args.decoding)

    if args.save_file_path:
            encoded_passes.to_csv(args.save_file_path, index=False)


