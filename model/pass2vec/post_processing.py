import argparse
import logging
import numpy
import pandas
from MulticoreTSNE import MulticoreTSNE as TSNE
from sklearn.cluster import AgglomerativeClustering
from sklearn.cluster import KMeans

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing passes data")
    parser.add_argument("-t", "--tsne", help="compute T-SNE on encoded features", action="store_true", default=False)
    parser.add_argument("-a", "--ahc", help="clustering with agglomerative clustering", action="store_true", default=False)
    parser.add_argument("-k", "--kmeans", help="clustering with K-means", action="store_true", default=False)
    parser.add_argument("-n", "--n_clusters", help="number of clusters", type=int, default=10)
    parser.add_argument("-s", "--save_file_path", help="file path to save data", default="model/pass2vec/resources/post_processed_data.csv")
    args = parser.parse_args()

    logging.getLogger().setLevel(logging.INFO)

    logging.info("Loading data...")
    post_processed_data = pandas.read_csv(args.data).dropna(axis=0)
    
    if args.tsne:
        logging.info("TSNE computing...")
        tsne_result = TSNE(n_jobs=4, n_components=2, perplexity=30, n_iter=2000, random_state=8).fit_transform(post_processed_data.filter(regex="f_"))
        tsne_dataframe = pandas.DataFrame(data=tsne_result, columns=["t1", "t2"])
        post_processed_data = pandas.concat((post_processed_data, tsne_dataframe), axis=1)

    if args.ahc:
        logging.info("Agglomerative Hierarchical Clustering computing...")
        ahc_result = AgglomerativeClustering(n_clusters=args.n_clusters).fit(post_processed_data.filter(regex="f_")).labels_
        ahc_dataframe = pandas.DataFrame(data=ahc_result, columns=["ahc_cluster"])
        post_processed_data = pandas.concat((post_processed_data, ahc_dataframe), axis=1)

    if args.kmeans:
        logging.info("K-means computing...")
        kmeans_result = KMeans(n_clusters=args.n_clusters).fit(post_processed_data.filter(regex="f_")).labels_
        kmeans_dataframe = pandas.DataFrame(data=kmeans_result, columns=["kmeans_cluster"])
        post_processed_data = pandas.concat((post_processed_data, kmeans_dataframe), axis=1)

    if args.save_file_path:
        logging.info("Saving file...")
        post_processed_data.to_csv(args.save_file_path, index=False)
