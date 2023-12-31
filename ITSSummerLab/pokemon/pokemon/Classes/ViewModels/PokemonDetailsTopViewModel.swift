//
//  PokemonDetailsTopViewModel.swift
//  pokemon
//
//  Created by Márcio Duarte on 15/04/2022.
//
//  ViewModel used to call services to retrive additional information about pokemon before start the layout construction
//  Class used on PokemonDetailsTopView

import Foundation
import UIKit

class PokemonDetailsTopViewModel: NSObject {

    // MARK: - Private vars
    /// Var used to set the pokemons details receive from the service vall.
    /// This var call the bindPokemonDetails to send to the view all the details necessary to show the screen
    private(set) var pokemonDetails: [PokemonDetails]! {
        didSet {
            DispatchQueue.main.async {
                self.bindPokemonDetails(self.pokemonDetails)
            }
        }
    }

    /// Used to comunicate with service protocol to call services.
    private var pokemonServiceAPI: PokemonServiceProtocol


    // MARK: - Public vars
    /// Bind to inform View to update details tableview
    var bindPokemonDetails: (([PokemonDetails]) -> ()) = {_ in}

    /// Bind to inform View to update details tableview
    var bindErrorToGetAbilities: (() -> ()) = {}

    /// Pokemon selected to show details
    public var pokemon: Pokemon!

    /// Segmented control state
    /// This var is setted after the user change the index of the segmented control and after this, call and return the details by the var - pokemonDetails -
    public var pokemonDetailSegmentedSelected: PokemonDetailSegmentedSelected = .About {
        didSet {
            self.getPokemonAdditionalInformation()

            PokemonsUtils().hideActivityView()
        }
    }

    // MARK: - Life Cycles
    /// Init Pokemon service api  protocol.
    init (pokemonAPI: PokemonServiceProtocol = PokemonWebServices()) {
        self.pokemonServiceAPI = pokemonAPI
    }

    /// Create about information details of pokemon
    private func getAbountDetails() {
        var pokemonDetails: [PokemonDetails] = []

        // Cell Id
        pokemonDetails.append(PokemonDetails(detailsTitle: PokemonAboutDetailType.IdType.description, detailsDescriptionTitle: String(describing: self.pokemon.id!), detailsDescription: "", detailsSubDescription: ""))

        // Cell Name
        pokemonDetails.append(PokemonDetails(detailsTitle: PokemonAboutDetailType.NameType.description, detailsDescriptionTitle: self.pokemon.name?.capitalized ?? "-", detailsDescription: "", detailsSubDescription: ""))
        
        // Cell Type
        var pokemonTypes = ""
        if let types = self.pokemon.types{
            
            for pokemonType in types {
                
                pokemonTypes += pokemonType.type?.name ?? ""
                pokemonTypes += "; "
            }
                    
        }
        
       
        pokemonDetails.append(PokemonDetails(detailsTitle: PokemonAboutDetailType.PokemonType.description, detailsDescriptionTitle: pokemonTypes.capitalized , detailsDescription: "", detailsSubDescription: ""))

        // Cell Weight
        
        pokemonDetails.append(PokemonDetails(detailsTitle: PokemonAboutDetailType.WeightType.description, detailsDescriptionTitle: String(describing: self.pokemon.weight!), detailsDescription: "", detailsSubDescription: ""))
        //ACADEMIA: neste array de pokemonDetails, podes adicionar mais campos dos seus detalhes que aches interessante mostrar sobre cada pokemon, usando o número e nome como exemplos
        
        // Cell Height
        
        pokemonDetails.append(PokemonDetails(detailsTitle: PokemonAboutDetailType.HeightType.description, detailsDescriptionTitle: String(describing: self.pokemon.height!), detailsDescription: "", detailsSubDescription: ""))
        
        self.pokemonDetails = pokemonDetails

        PokemonsUtils().hideActivityView()
    }

    // Check pokemon object data
    private func hasPokemonObject(withPokemon pokemon: Pokemon?) -> Bool {
        return pokemon != nil && pokemon?.abilities != nil && pokemon?.abilities?.count ?? 0 != 0
    }

    /// Identifie and reate the detail object based of the segmented control
    public func getPokemonDetails() {
        switch self.pokemonDetailSegmentedSelected {
        case .Abilities:
            self.getAbilitiesDetails()
        case .Stats:
            self.getStatsDetails()
        default:
            self.getAbountDetails()
        }
    }

    /// Create abilities object information details of pokemon
    public func getAbilitiesDetails() {
        var pokemonDetails: [PokemonDetails] = []

        // For each ability will get the explanatory details of each one of them and construct the PokemonDetails object
        self.pokemon.abilities?.forEach({ ability in
            if let hidden = ability.is_hidden, !hidden {

                ability.ability?.effect_entries?.forEach({ effectEntries in
                    if self.isEffectEntriesInEnIdiom(withLanguageName: effectEntries.language?.name ?? "") {
                        // Ability cell
                        pokemonDetails.append(self.getAbilityDetailInformation(withAbility: ability.ability!, andEffectEntries: effectEntries))
                    }
                })
            }
        })

        self.pokemonDetails = pokemonDetails

        PokemonsUtils().hideActivityView()
    }
    
    /// Get pokemons additional information
    /// This method get all abilities of the pokemon and after that get the details of the abilities que devem ser apresentados
    public func getPokemonAdditionalInformation() {
        PokemonsUtils().showActivityView()

        if self.hasPokemonObject(withPokemon: self.pokemon), let abilityFetched = self.pokemon.abilities?.first?.isAbilityFetched, !abilityFetched {
            Task { [weak self] in
                guard let self = self else {
                    PokemonsUtils().hideActivityView()

                    return
                }

                do {
                    if let abilities = self.pokemon.abilities {
                        var index: Int = 0
                        for ability in abilities {
                            // Get abilities of the pokemon
                            let newAbility: Ability!
                            if let urlString = ability.ability?.url, index <= (self.pokemon.abilities?.count ?? 0) {
                                newAbility = try await self.pokemonServiceAPI.getPokemonAbilities(withURLString: urlString)
                                self.pokemon.abilities?[index].ability = newAbility
                                self.pokemon.abilities?[index].isAbilityFetched = true
                            }
                            index += 1
                        }
                    }
                } catch {
                    let errorData: [String: Error] = [errorType: error]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: PokemonErrorServiceNotification), object: errorData)

                    return
                }
            }
        } else if self.pokemonDetailSegmentedSelected == .Abilities && !self.hasPokemonObject(withPokemon: self.pokemon) {
            let errorData: [String: Error] = [errorType: PokemonsError.MissingData]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PokemonErrorServiceNotification), object: errorData)

            self.bindErrorToGetAbilities()
            return
        }

        self.getPokemonDetails()
    }

    // Check if the language of the ability is equal to the default language
    public func isEffectEntriesInEnIdiom(withLanguageName languageName: String) -> Bool {
        return languageName == Constants().kENLanguage
    }

    // Create the PokemonDetail to abilities
    public func getAbilityDetailInformation(withAbility ability: Ability, andEffectEntries effectEntries: EffectEntries) -> PokemonDetails {
        let effect: String = "\(NSLocalizedString("pokemon.cell.effect", comment: "") + (effectEntries.effect ?? "-"))"
        let shortEffect: String = "\(NSLocalizedString("pokemon.cell.short.effect", comment: "") + (effectEntries.short_effect ?? "-"))"

        return PokemonDetails(detailsTitle: PokemonAbilitiesDetail.Ability.description, detailsDescriptionTitle: ability.name?.capitalized ?? "-", detailsDescription: effect, detailsSubDescription: shortEffect)
    }

    /// Create stats object information details of pokemon
    private func getStatsDetails() {
        var pokemonDetails: [PokemonDetails] = []

        // For each stats will create a cell with information of the pokemon stats
        self.pokemon.stats?.forEach({ stats in
            let statName = stats.stat?.name?.capitalized
            let baseState = String(describing: stats.base_stat!)

            // Cell Speed
            pokemonDetails.append(PokemonDetails(detailsTitle: statName ?? "-", detailsDescriptionTitle: baseState, detailsDescription: "", detailsSubDescription: ""))
        })

        self.pokemonDetails = pokemonDetails

        PokemonsUtils().hideActivityView()
    }
}
