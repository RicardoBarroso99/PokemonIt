//
//  PokemonCell.swift
//  pokemon
//
//  Created by Márcio Duarte on 11/04/2022.
//

import UIKit

class PokemonCell: UICollectionViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    // MARK: - Public vars
    static let identifier = "PokemonCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupUI()
    }

    private func setupUI() {
        self.contentViewCell.layer.cornerRadius = 16.0
        self.contentViewCell.backgroundColor = UIColor.pokemonCellBackgroundColor.withAlphaComponent(0.5)

        self.activityIndicator.accessibilityElementsHidden = true
    }

    override func prepareForReuse() {
        self.resetCell()
    }

    private func resetCell() {
        //ACADEMIA: aqui deverás fazer reset à UI toda da cell (meter labels a @"", remover a imagem, etc
        self.label?.text = ""
        self.image?.image = nil

        
        self.contentViewCell.backgroundColor = UIColor.pokemonCellBackgroundColor.withAlphaComponent(0.5)
       
        self.activityIndicator.isHidden = true
        self.isUserInteractionEnabled = true
    }

    /// Method with configurations of the cell when we need a pokemon information cell
    /// This method is used to present the pokemon information on pokemon list collection view
    /// This method receive a pokemon object
    public func configCell(withPokemon pokemon: Pokemon) {
        //ACADEMIA: aqui deverás configurar a cell de cada pokemon
        self.label?.text = pokemon.name
        self.label?.textColor = .white
   //     self.image?.image = pokemon.sprites?.frontDefaultData
        let image = UIImage(data: pokemon.sprites?.frontDefaultData ?? Data())
        self.image?.image = image
        
        self.contentViewCell.backgroundColor = .pokemonRedColor
        
        

    }

    /// Method with configurations of the cell when we need a loading view cell
    /// This method is used when the app wait for service responde after scroll on pokemon list collection view
    public func configLoadingView() {
        self.resetCell()

        self.contentViewCell.backgroundColor = UIColor.pokemonListBackgroundColor

        self.activityIndicator.style = UIActivityIndicatorView.Style.large
        self.activityIndicator.color = UIColor.pokemonRedColor
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false

        self.isUserInteractionEnabled = false
    }
}
