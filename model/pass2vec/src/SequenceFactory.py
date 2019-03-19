from model.pass2vec.src.Pass import Pass
from model.pass2vec.src.Sequence import Sequence
from itertools import islice, tee
import pandas
import numpy
import cv2
import datetime


class SequencesFactory:

    @staticmethod
    def to_bin(value, step):
        return numpy.floor(value / step) * step

    def build_pass_list(self, data):
        """Build a pass list from a dataframe (and process row data).

        Args:
            data: A pandas dataframe containing passes informations.

        Returns:
            A list of pass instances.
        """
        pass_list = []
        for index, row in data.iterrows():
            pass_data = Pass(
                self.to_bin(row["x_begin"], 2), 
                self.to_bin(row["y_begin"], 2), 
                self.to_bin(row["x_end"], 2), 
                self.to_bin(row["y_end"], 2), 
                row["game_id"], 
                row["team_id"],
                row["event_id"])
            pass_list.append(pass_data)
        return pass_list

    @staticmethod
    def build_sequences(pass_list):
        """Build passses sequences from a list of pass.

        Args:
            pass_list: A list of pass instances.

        Returns:
            A list of sequence instances.
        """
        sequences = []
        pass_sequence = []
        for i in range(0, len(pass_list)-1):
            if pass_list[i].sequence_id == pass_list[i-1].sequence_id and pass_list[i].sequence_id != pass_list[i+1].sequence_id:
                pass_sequence.append(pass_list[i])
            if pass_list[i].sequence_id == pass_list[i+1].sequence_id:
                pass_sequence.append(pass_list[i])
            else:
                if len(pass_sequence) > 1:
                    sequences.append(Sequence(pass_sequence))
                pass_sequence = []
        return sequences


    def build_data(self, sequences, save_img=False):
        result = []
        for sequence in sequences:
            if len(sequence.pass_list) > 1:
                row_image = sequence.to_vec(save_img)
                result.append(row_image)
        return numpy.array(result)
        

    # def build_data(self, sequences, starting_window, ending_window):
    #     null_pass = Pass(0, 0, 0, 0)
    #     processed_sequences = []
    #     header = list(numpy.array([[f"pass{i}_x_begin", f"pass{i}_y_begin", f"pass{i}_x_end", f"pass{i}_y_end"] for i in range(ending_window)]).flatten())
    #     header += ["game_id", "team_id", "sequence_length"]
    #     for sequence in sequences:
    #         if len(sequence) >= starting_window and len(sequence) <= ending_window:
    #             padded_sequence = self.change_sequence_referentiel(sequence) + [null_pass for i in range(0, ending_window  len(sequence))]
    #             processed_sequences.append(
    #                 list(numpy.array([passe.geo for passe in padded_sequence]).flatten()) +
    #                 [padded_sequence[0].game_id] + 
    #                 [padded_sequence[0].team_id] + 
    #                 [len(sequence)])
    #     return pandas.DataFrame(processed_sequences, columns=header)


    
    # @staticmethod
    # def sequ_pairs(sequence):
    #     elem1, elem2 = tee(sequence, 2)
    #     return zip(elem1, islice(elem2, 1, None))

    # def sequences_to_training_data(self, sequences):
    #     training_data = []
    #     for sequence in sequences:
    #         if sequence:    
    #             abstract_sequence = sequence
    #             for elem1, elem2 in self.sequ_pairs(abstract_sequence):
    #                 training_data.append(elem1.geo + elem2.geo)
    #                 training_data.append(elem2.geo + elem1.geo)
    #     header = [
    #         "passA_x_begin", "passA_y_begin", "passA_x_end", "passA_y_end",
    #         "passB_x_begin", "passB_y_begin", "passB_x_end", "passB_y_end"]
    #     return pandas.DataFrame(training_data, columns=header)
                    

