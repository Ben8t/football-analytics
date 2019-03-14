from model.pass2vec.src.Pass import Pass
from itertools import islice, tee
import pandas
import numpy


class SequencesFactory:

    @staticmethod
    def build_pass_list(data):
        """
        Build a pass list from a dataframe (and process row data)
        """
        pass_list = []
        for index, row in data.iterrows():
            pass_data = Pass(
                round(row["x_begin"], 0), 
                round(row["y_begin"], 0), 
                round(row["x_end"], 0), 
                round(row["y_end"], 0), 
                row['game_id'], 
                row['team_id'])
            pass_list.append(pass_data)
        return pass_list

    @staticmethod
    def build_sequences(pass_list):
        """
        Build passses sequences from a list of pass
        """
        sequences = []
        pass_sequence = []
        for i in range(0, len(pass_list)-1):
            if pass_list[i].id == pass_list[i-1].id and pass_list[i].id != pass_list[i+1].id:
                pass_sequence.append(pass_list[i])
            if pass_list[i].id == pass_list[i+1].id:
                pass_sequence.append(pass_list[i])
            else:
                pass_sequence = []
                sequences.append(pass_sequence)
        return sequences

    @staticmethod
    def change_sequence_referentiel(sequence):
        x_init = sequence[0].x_begin
        y_init = sequence[0].y_begin
        new_sequence = []
        for passe in sequence:
            new_passe = Pass(
                passe.x_begin - x_init,
                passe.y_begin - y_init,
                passe.x_end - x_init,
                passe.y_end - y_init)
            new_sequence.append(new_passe)
        return new_sequence

    def build_data(self, sequences, starting_window, ending_window):
        null_pass = Pass(0, 0, 0, 0)
        processed_sequences = []
        header = list(numpy.array([[f"pass{i}_x_begin", f"pass{i}_y_begin", f"pass{i}_x_end", f"pass{i}_y_end"] for i in range(ending_window)]).flatten())
        for sequence in sequences:
            if len(sequence) >= starting_window and len(sequence) <= ending_window:
                padded_sequence = self.change_sequence_referentiel(sequence) + [null_pass for i in range(0, ending_window - len(sequence))]
                processed_sequences.append(list(numpy.array([passe.geo for passe in padded_sequence]).flatten()))
        print(processed_sequences[0])
        print(header)
        return pandas.DataFrame(processed_sequences, columns=header)


    
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
                    

