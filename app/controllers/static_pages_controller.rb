class StaticPagesController < ApplicationController
  def index
    @countries = Country.all
    @players = Player.all
  end
end
