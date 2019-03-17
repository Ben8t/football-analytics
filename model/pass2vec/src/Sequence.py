from model.pass2vec.src.Pass import Pass
import numpy
import cv2

class Sequence:

    def __init__(self, pass_list):
        self.__pass_list = pass_list
        self.__id = "_".join([str(pass_list[0].game_id) + str(pass_list[0].team_id)] + [passe.event_id for passe in pass_list])
        self.__game_id = str(pass_list[0].game_id)
        self.__team_id = str(pass_list[0].team_id)
        self.__player_list = [passe.player_id for passe in pass_list]

    @property
    def id(self):
        return self.__id

    @property
    def pass_list(self):
        return self.__pass_list

    @property
    def player_list(self):
        return self.__player_list
        
    def change_referentiel(self):
        x_init = self.__pass_list[0].x_begin
        y_init = self.__pass_list[0].y_begin
        new_sequence = []
        for passe in self.__pass_list:
            new_passe = Pass(
                passe.x_begin - x_init,
                passe.y_begin - y_init,
                passe.x_end - x_init,
                passe.y_end - y_init,
                self.__pass_list[0].game_id,
                self.__pass_list[0].team_id,
                passe.event_id)
            new_sequence.append(new_passe)
        return Sequence(new_sequence)

    def to_vec(self, save=False):
        img = numpy.zeros((128,128,1), numpy.uint8)
        colors = [int(155 + i * (255-155)/(len(self.__pass_list)-1)) for i in range(0, len(self.__pass_list))]
        for i, passe in zip(range(len(self.__pass_list)), self.__pass_list):
            img = cv2.line(img, (int(passe.x_begin),int(passe.y_begin)), (int(passe.x_end),int(passe.y_end)), (colors[i],0,0), 1)
        if save:
            img_folder = "model/pass2vec/resources"
            cv2.imwrite(f"{img_folder}/seq_{self.__id}.png", img)
        return img.flatten()
