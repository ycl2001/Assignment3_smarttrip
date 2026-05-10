//
//  AddFlightView.swift
//  Assignment3_SmartTrip
//

import SwiftUI

struct AddFlightView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchVM = FlightSearchViewModel()

    let flightToEdit: Flight?
    var onSave: (Flight) -> Void

    // Search bar state
    @State private var searchFlightNumber = ""
    @State private var searchDate         = Date()

    // Form fields (auto-filled by search or entered manually)
    @State private var flightNumber:     String    = ""
    @State private var airline:          String    = ""
    @State private var departureAirport: String    = ""
    @State private var arrivalAirport:   String    = ""
    @State private var departureTime:    Date      = Date()
    @State private var arrivalTime:      Date      = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    @State private var seatClass:        SeatClass = .economy
    @State private var confirmationCode: String    = ""
    @State private var notes:            String    = ""

    // Validation
    @State private var flightNumberError:     String? = nil
    @State private var airlineError:          String? = nil
    @State private var departureAirportError: String? = nil
    @State private var arrivalAirportError:   String? = nil

    private var isEditing: Bool { flightToEdit != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(isEditing ? "Edit your flight" : "Add a new flight")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                        .padding(.horizontal)

                    // Search card only shown when adding (not editing)
                    if !isEditing {
                        searchCard
                    }

                    detailsCard
                    routeCard
                    scheduleCard
                    extrasCard

                    saveButton
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Flight" : "Add Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: populateForEditing)
            // Auto-fill form when search returns a result
            .onChange(of: searchVM.result) { _, result in
                guard let r = result else { return }
                flightNumber     = r.flightNumber
                airline          = r.airline
                departureAirport = r.departureAirport
                arrivalAirport   = r.arrivalAirport
                departureTime    = r.departureTime
                arrivalTime      = r.arrivalTime
                // clear validation errors that might have been set
                flightNumberError     = nil
                airlineError          = nil
                departureAirportError = nil
                arrivalAirportError   = nil
            }
        }
    }

    // MARK: - Card helper

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
        .padding(.horizontal)
    }

    // MARK: - Search card

    private var searchCard: some View {
        card {
            Text("Search by flight number")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("e.g. QF1, SQ22, EK407", text: $searchFlightNumber)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()

            Divider()

            DatePicker("Date", selection: $searchDate, displayedComponents: .date)

            // Error / result feedback
            if let err = searchVM.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else if searchVM.result != nil {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Flight found — fields filled below")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            Button {
                Task {
                    await searchVM.search(
                        flightNumber: searchFlightNumber,
                        date: searchDate
                    )
                }
            } label: {
                HStack {
                    if searchVM.isSearching {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text(searchVM.isSearching ? "Searching…" : "Search Flight")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .disabled(searchVM.isSearching)

            Text("Or fill in the details manually below")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Form cards

    private var detailsCard: some View {
        card {
            Text("Details")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                TextField("Flight number  (e.g. QF1)", text: $flightNumber)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onChange(of: flightNumber) { _, _ in flightNumberError = nil }
                if let err = flightNumberError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                TextField("Airline  (e.g. Qantas)", text: $airline)
                    .onChange(of: airline) { _, _ in airlineError = nil }
                if let err = airlineError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var routeCard: some View {
        card {
            Text("Route")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "airplane.departure")
                        .foregroundStyle(.secondary)
                    TextField("Departure airport  (e.g. SYD)", text: $departureAirport)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: departureAirport) { _, _ in departureAirportError = nil }
                }
                if let err = departureAirportError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "airplane.arrival")
                        .foregroundStyle(.secondary)
                    TextField("Arrival airport  (e.g. NRT)", text: $arrivalAirport)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .onChange(of: arrivalAirport) { _, _ in arrivalAirportError = nil }
                }
                if let err = arrivalAirportError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var scheduleCard: some View {
        card {
            Text("Schedule")
                .font(.caption)
                .foregroundStyle(.secondary)

            DatePicker("Departure", selection: $departureTime)
                .onChange(of: departureTime) { _, newDep in
                    if arrivalTime <= newDep {
                        arrivalTime = Calendar.current.date(byAdding: .hour, value: 3, to: newDep) ?? newDep
                    }
                }

            Divider()

            DatePicker("Arrival", selection: $arrivalTime, in: departureTime...)
        }
    }

    private var extrasCard: some View {
        card {
            Text("Extras")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Seat Class", selection: $seatClass) {
                ForEach(SeatClass.allCases) { c in Text(c.rawValue).tag(c) }
            }
            .pickerStyle(.menu)

            Divider()

            TextField("Booking / confirmation code", text: $confirmationCode)

            Divider()

            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(isEditing ? "Update" : "Save")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Logic

    private func populateForEditing() {
        guard let f = flightToEdit else { return }
        flightNumber     = f.flightNumber
        airline          = f.airline
        departureAirport = f.departureAirport
        arrivalAirport   = f.arrivalAirport
        departureTime    = f.departureTime
        arrivalTime      = f.arrivalTime
        seatClass        = f.seatClass
        confirmationCode = f.confirmationCode
        notes            = f.notes
    }

    @discardableResult
    private func validate() -> Bool {
        var valid = true
        if flightNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            flightNumberError = "Enter a flight number"; valid = false
        }
        if airline.trimmingCharacters(in: .whitespaces).isEmpty {
            airlineError = "Enter the airline name"; valid = false
        }
        if departureAirport.trimmingCharacters(in: .whitespaces).isEmpty {
            departureAirportError = "Enter departure airport"; valid = false
        }
        if arrivalAirport.trimmingCharacters(in: .whitespaces).isEmpty {
            arrivalAirportError = "Enter arrival airport"; valid = false
        }
        return valid
    }

    private func save() {
        guard validate() else { return }
        let flight = Flight(
            id:               flightToEdit?.id ?? UUID(),
            flightNumber:     flightNumber.trimmingCharacters(in: .whitespaces).uppercased(),
            airline:          airline.trimmingCharacters(in: .whitespaces),
            departureAirport: departureAirport.trimmingCharacters(in: .whitespaces).uppercased(),
            arrivalAirport:   arrivalAirport.trimmingCharacters(in: .whitespaces).uppercased(),
            departureTime:    departureTime,
            arrivalTime:      arrivalTime,
            seatClass:        seatClass,
            confirmationCode: confirmationCode.trimmingCharacters(in: .whitespaces),
            notes:            notes.trimmingCharacters(in: .whitespaces)
        )
        onSave(flight)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Add Flight") {
    AddFlightView(flightToEdit: nil) { _ in }
}
