from model.pass2vec.src.Pass import Pass
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
        """
        Build a pass list from a dataframe (and process row data)
        """
        pass_list = []
        for index, row in data.iterrows():
            pass_data = Pass(
                self.to_bin(row["x_begin"], 2), 
                self.to_bin(row["y_begin"], 2), 
                self.to_bin(row["x_end"], 2), 
                self.to_bin(row["y_end"], 2), 
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
                passe.y_end - y_init,
                sequence[0].game_id,
                sequence[0].team_id)
            new_sequence.append(new_passe)
        return new_sequence

    @staticmethod
    def sequence_to_vec(sequence, save=False):
        img = numpy.zeros((128,128,1), numpy.uint8)
        colors = [int(155 + i * (255-155)/(len(sequence)-1)) for i in range(0, len(sequence))]
        for i, passe in zip(range(len(sequence)), sequence):
            img = cv2.line(img, (int(passe.x_begin),int(passe.y_begin)), (int(passe.x_end),int(passe.y_end)), (colors[i],0,0), 1)
        if save:
            img_folder = "model/pass2vec/resources"
            now = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
            cv2.imwrite(f"{img_folder}/seq_{now}.png", img)
        return img.flatten()

    def build_data(self, sequences):
        result = []
        for sequence in sequences:
            if len(sequence) > 1:
                print(len(sequence))
                row_image = self.sequence_to_vec(sequence, True)
                result.append(row_image)
        return result
        

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
                    

