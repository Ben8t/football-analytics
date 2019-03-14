"""
Pass.py
A simple class to declare a pass information
"""

class Pass:

    def __init__(self, x_begin, y_begin, x_end, y_end, game_id=None, team_id=None):
        self.__x_begin = x_begin
        self.__y_begin = y_begin
        self.__x_end = x_end
        self.__y_end = y_end
        self.__game_id = game_id
        self.__team_id = team_id

    @property
    def game_id(self):
        return self.__game_id

    @property
    def team_id(self):
        return self.__team_id

    @property
    def x_begin(self):
        return self.__x_begin

    @property
    def y_begin(self):
        return self.__y_begin

    @property
    def x_end(self):
        return self.__x_end

    @property
    def y_end(self):
        return self.__y_end

    @property
    def geo(self):
        return [self.x_begin, self.y_begin, self.x_end, self.y_end]

    @property
    def id(self):
        return str(self.game_id) + str(self.team_id)