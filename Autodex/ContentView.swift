//
//  ContentView.swift
//  Autodex
//
//  Created by Alyssia Frey and Lucas Cesar on 29/05/2026.

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body : some View {
        VStack(alignment: .leading, spacing: 4) {

            //Titre
            
            Text("AutoDex")
            .font(.largeTitle)
            .foregroundStyle(Color(red: 131/255, green: 170/255, blue: 131/255))

            .fontWeight(.bold)
            
            // Texte recherche
            
             Text("Faites votre choix de véhicules en comparant leur caractéristiques")
             .font(.caption)
             .padding(.bottom, 30)
            
            // Buttoon filtre
            
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("Rechercher un véhicule", text: .constant(""))
                    .font(.caption)
        
                Spacer()
            
                
            }
            .padding(10)
            .foregroundStyle(.black)
            .background(Color(red: 225/255, green: 225/255, blue: 225/255))
            .cornerRadius(25)
            
            .padding(.bottom, 20)
            HStack {
                
                Button("Populaires"){
                
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.yellow)
                .cornerRadius(30)

                Button("Nouveautés"){
                
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            

        }
        .padding(20)
        .foregroundStyle(Color(red: 176/255, green: 176/255, blue: 176/255))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
       
        

        
        
        
       
    }
    
   
    
}
