"""
Pass2Vec model application
Encode sequence of passes

Usage :
python -m model.pass2vec.main <pass_data_file.csv>

Wildcard:
-s input for saving file

"""
import argparse
import numpy
import pandas
import cv2
from model.pass2vec.src.SequenceFactory import SequencesFactory
from keras.models import load_model
from sklearn.manifold import TSNE

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
    img_data = vector.reshape(width, height) * 255.
    cv2.imwrite(f"{img_folder}/seq_decoded_{id}.png", img_data)
    return img_data

def model_application(models, data, decoding=False):
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
    encoded_img = models["encoder_model"].predict(processed_data)
    if decoding:
        for id, img in zip(sequences_informations["id"], encoded_img):
            vec_to_img(models["decoder_model"].predict(numpy.array([img])), id)
    
    reducted_img = TSNE(n_components=2, perplexity=20, n_iter=250, random_state=8).fit_transform(encoded_img)

    header = [f"f_{i}" for i in range(0, encoded_img.shape[1])]
    encoded_pass = pandas.DataFrame(data=encoded_img, columns=header)
    reducted_pass = pandas.DataFrame(data=reducted_img, columns=["t1", "t2"])
    return pandas.concat((sequences_informations, encoded_pass, reducted_pass), axis=1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing passes data")
    parser.add_argument("-d", "--decoding", help="saving decoded images.", action="store_true", default=False)
    parser.add_argument("-s", "--save", help="input for saving file", action="store_true")
    args = parser.parse_args()

    encoder_model = load_model('mlruns/0/0654c29c27d544d0a5e0e1593a38eee7/artifacts/encoder_model/model.h5')
    decoder_model = load_model('mlruns/0/0654c29c27d544d0a5e0e1593a38eee7/artifacts/decoder_model/model.h5')
    models = {"encoder_model": encoder_model, "decoder_model": decoder_model}
    pass_data = pandas.read_csv(args.data).dropna(axis=0).head(100)
    encoded_passes = model_application(models, pass_data, args.decoding)

    # Saving option
    if args.save:
            file_path = input("File path (for example /Users/username/folder/file.csv): ")
            encoded_passes.to_csv(file_path, index=False)


