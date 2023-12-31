//
//  PokemonDetailsBottomView.swift
//  pokemon
//
//  Created by Márcio Duarte on 13/04/2022.
//
//  PokemonDetailsBottomView is the UIView with pokemon name and the front/back pokemon image

import UIKit

class PokemonDetailsBottomView: UIView {

    // MARK: - IBOutlet
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var pokemonView: UIView!
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var swipeLeftImageView: UIImageView!
    @IBOutlet weak var swipeRightImageView: UIImageView!

    @IBOutlet weak var pokemonName: UILabel!
    // MARK: - Private vars
    /// Flag to check if the front pokemon image is visible or not
    private var shownFrontPokemonVisivel: Bool = false

    // MARK: - Public vars
    /// Var with pokemon selected by the user.
    /// When this var is setted, the setupUI is called and update/create the layout based on the pokemon selected.
    public var pokemon: Pokemon! {
        didSet {
            DispatchQueue.main.async {
                self.setupUI()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configContent()
    }

    private func configContent() {
        Bundle.main.loadNibNamed(String(describing: PokemonDetailsBottomView.self), owner: self, options: nil)
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        self.addSubview(self.contentView)
    }

    private func setupUI() {
        self.imageViewContainer.layer.cornerRadius = self.imageViewContainer.frame.height / 2
        self.pokemonImageView.layer.cornerRadius = self.pokemonImageView.frame.height / 2
        self.pokemonView.layer.cornerRadius = self.pokemonView.frame.height / 2
        self.pokemonView.setShadow()
        self.bottomView.layer.cornerRadius = self.bottomView.frame.height / 2

        if let frontImageData = self.pokemon.sprites?.frontDefaultData {
            //ACADEMIA: o self.pokemonImageView deverá mostrar a imagem que acabamos de fazer unwrap
            let image = UIImage(data: frontImageData)
            
            self.pokemonImageView.image = image
            
            
        }
        self.setDefautSwipeLeftRightImage()

        self.imageViewContainer.backgroundColor = UIColor.white
        self.imageViewContainer.backgroundColor = UIColor.pokemonColorsDict[self.pokemon.types?.first?.type?.name ?? ""]
        self.bottomView.backgroundColor = UIColor.pokemonColorsDict[self.pokemon.types?.first?.type?.name ?? ""]

        //ACADEMIA: Podes adicionar uma UILabel a esta view para mostrar o nome do Pokemon à beira das sua imagem
        self.pokemonName.text = pokemon.name
        self.pokemonName.textColor = .pokemonListBackgroundColor
        // Add tap gesture recognizer to pokemon image to show front and back pokemon
        self.addPokemonGestureRecognizer()
    }

    /// Update and set the default configuration to show the swipes left/right information
    public func setDefautSwipeLeftRightImage() {
        self.swipeLeftImageView.isHidden = true
        self.swipeRightImageView.isHidden = false
        self.shownFrontPokemonVisivel = false
    }

    // Add left/right gesture recognizer to the view
    private func addPokemonGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.changeImageGesture(_:)))
        swipeRight.direction = .right
        self.imageViewContainer.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.changeImageGesture(_:)))
        swipeLeft.direction = .left
        self.imageViewContainer.addGestureRecognizer(swipeLeft)
    }

    @objc func changeImageGesture(_ sender: UIGestureRecognizer) {
        if let swipeGesture = sender as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                if shownFrontPokemonVisivel {
                    self.swipeLeftImageView.isHidden = true
                    self.swipeRightImageView.isHidden = false
                    self.shownFrontPokemonVisivel = !self.shownFrontPokemonVisivel
                    self.pokemonImageView.alpha = 0.0
                    if let frontData = self.pokemon.sprites?.frontDefaultData {
                        //ACADEMIA: o self.pokemonImageView deverá mostrar a imagem que acabamos de fazer unwrap
                        let image = UIImage(data: frontData)
                        
                        self.pokemonImageView.image = image

                    }
                }
            case .left:
                if !shownFrontPokemonVisivel {
                    self.swipeLeftImageView.isHidden = false
                    self.swipeRightImageView.isHidden = true
                    self.shownFrontPokemonVisivel = !self.shownFrontPokemonVisivel
                    self.pokemonImageView.alpha = 0.0
                    if let backData = self.pokemon.sprites?.backDefaultData {
                        //ACADEMIA: o self.pokemonImageView deverá mostrar a imagem que acabamos de fazer unwrap
                        
                        let image = UIImage(data: backData)
                        
                        self.pokemonImageView.image = image

                    }
                }
            default:
                break
            }

            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut, animations: {
                self.pokemonImageView.alpha = 1.0
            }, completion: nil)
        }
    }
}
