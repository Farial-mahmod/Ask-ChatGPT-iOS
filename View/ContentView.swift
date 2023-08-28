//  ContentView.swift
//  Ask ChatGPT iOS
//  Created by Farial Mahmod on 8/24/23.

import SwiftUI
import Foundation
import Combine

struct ContentView : View {
    
    // array to store temporary messages
    @State var chatMessages : [ChatMessage] = []
    
    // to be interpolated later as needed
    @State var messageText: String = ""
    
    // for executing closures following a cancellation
    @State var cancellables = Set<AnyCancellable>()
    
    // instance of OpenAIService() service class
    let openAIService = OpenAIService()

    // the focal view
    var body : some View {
        
        VStack{
            
            Spacer()
            
            // title
            Text("Ask ChatGPT")
                .font(.title)
                .bold()
                .foregroundStyle(LinearGradient(
                    colors: [.blue, .red], startPoint: .leading, endPoint: .trailing
                ))
            
            Group {
                Spacer()
                Spacer()
                Spacer()
            }
            
            // messages are to scrollable in nature
            ScrollView{
                LazyVStack{
                    ForEach(chatMessages, id: \.id){ message in
                        messageView(message: message)
                    }
                }
            }
            .padding()
            
            HStack{
                
                // textfield to write messages
                TextField("Write your question:", text: $messageText){
                    sendMessage()
                }
                .bold()
                .foregroundColor(.black)
                .padding()
                .cornerRadius(19)
                .background(.gray.opacity(0.11))
                
                // button to send messages
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send").padding()
                }
                .foregroundColor(.white)
                .background(.black)
                .padding()
                .cornerRadius(19)
            }
            .padding()
        }
    }
    
    // to show messages with custom properties
    func messageView(message: ChatMessage) -> some View {
        HStack{
            //
            if message.sender == .me { Spacer() }
            //
            Text(message.content)
                .padding()
                .background(message.sender == .me ? .purple : .blue.opacity(0.21))
                .foregroundColor(message.sender == .me ? .white : .black)
                .font(.title3)
            
            if message.sender == .gpt { Spacer() }
        }.cornerRadius(21)
    }
    
    // message sending (reactive) functionality
    func sendMessage(){
        
        let mymessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        
        // appending the messages to the array
        chatMessages.append(mymessage)
        
        // sink API sets up the subscriber for the exposed values reactively
        openAIService.sendMesssage(message: messageText).sink { completion in
        
        // receiving the reactive response
        } receiveValue: { response in
            
            // customizing the response that the subscriber listens to
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in:  .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else { return }
            
            // formation of response message by ChatGPT
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            
            // collecting the messages provided by ChatGPT
            chatMessages.append(gptMessage)
            
        }.store(in: &cancellables)
        messageText = ""
    }
}

    // preview
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

    // formation of each message
    struct ChatMessage {
        let id : String
        let content : String
        let dateCreated : Date
        let sender : MessageSender
    }

    // message by me or response by ChatGPT
    enum MessageSender{
        case me
        case gpt
    }

