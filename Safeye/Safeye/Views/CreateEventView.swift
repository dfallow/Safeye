//
//  CreateEventView.swift
//  Safeye
//
//  Created by gintare on 8.4.2022.
//  Edited by FUKA 11.4.2022

import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var EventVM: EventViewModel
    @EnvironmentObject var ConnectionVM: ConnectionViewModel
    @EnvironmentObject var appState: Store
    var translationManager = TranslationService.shared
    
    @State var authUID = AuthenticationService.getInstance.currentUser?.uid
    @State var startDate = Date()
    @State var endDate = Date()
    @State var eventType = ""
    //@State var locationDetails: String = ""
    @State var otherInfo: String = ""
    @State var eventFolderPath = ""
    
    @State var eventTypesArray = TranslationService.shared.eventTypesArray

    @State var cityOfEvent = ""
    @State var selectedEventCityIndex = 0
    
    @State var goEventView = false
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var cities: FetchedResults<City>
    
    @State private var showingFormError = false
    
    var body: some View {
        
        VStack{
            Form {
                Section(header: Text(translationManager.selectContactsTitle), footer: Text(translationManager.createEventInfoText)) {
                    SelectContactGridComponent()
                }
                
                
                Section(header: Text(translationManager.dateAndTime)) {
                    DatePicker(translationManager.startTime, selection: $startDate)
                    DatePicker(translationManager.endTime, selection: $endDate)
                }

                Section(header: Text(translationManager.eventType)) {
                    Picker(selection: $eventType, label: Text(translationManager.selectEventType)) {
                        ForEach(eventTypesArray, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                

                Section(header: Text(translationManager.location)) {

                    Picker(selection: $selectedEventCityIndex, label: Text("")) {
                        ForEach(0..<cities.count) {
                            Text(cities[$0].name!)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section(header: Text(translationManager.otherDetailTitle)) {
                    TextField(translationManager.detailPlaceholder, text: $otherInfo)
                }
                
            }.navigationBarTitle(translationManager.addEventInfo, displayMode: .inline)
                .alert("Please fill all form fields", isPresented: $showingFormError) { // TODO: translation
                    Button(translationManager.okBtn, role: .cancel) { }
                }
            Spacer()
            
            BasicButtonComponent(label: translationManager.saveActivateBtn, action: {
                print("City: \(cities[selectedEventCityIndex].name!)")
                if eventType.isEmpty || appState.eventSelctedContacts.isEmpty || otherInfo.isEmpty { showingFormError.toggle() ; print("Fill all fields") ; return }
                
                // set a random path for event folder and pass it to EventVM to createEvent()
                eventFolderPath = "events/\(UUID().uuidString)/"
                if EventVM.createEvent(startDate, endDate, otherInfo, eventType, cities[selectedEventCityIndex].name!, eventFolderPath) {
                    //goEventView.toggle()
                    //NavigationLink("", destination: EventView(), isActive: $goEventView)
                    dismiss()
                }
            })

            Text(translationManager.savingEventInfo)
                .font(.system(size: 15))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            EventVM.resetEventSelectedContacts()
            ConnectionVM.getConnections()
            ConnectionVM.getConnectionProfiles()
        }
        
    }
    
    
}

