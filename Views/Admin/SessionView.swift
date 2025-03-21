import SwiftUI

struct SessionView: View {
    @StateObject private var viewModel = SessionViewModel()
    @State private var showingAddSession = false
    @State private var selectedSession: Session?

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ForEach(viewModel.sessions, id: \._id) { session in
                        NavigationLink(value: session) {
                            SessionRowView(session: session)
                        }
                    }
                    .onDelete(perform: deleteSession)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSession = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                viewModel.fetchSessions()
            }
            .alert("Erreur", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(for: Session.self) { session in
                SessionFormView(mode: .edit, session: session, viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddSession) {
                SessionFormView(mode: .add, session: nil, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.fetchSessions()
        }
    }

    private func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            let session = viewModel.sessions[index]
            viewModel.deleteSession(session)
        }
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ID: \(session.id)")
                .font(.headline)
            Text("Début: \(session.startDate.formatted())")
            Text("Fin: \(session.endDate.formatted())")
            Text("Commission: \(session.commission)%")
        }
        .padding(.vertical, 4)
    }
}


struct SessionFormView: View {
    enum Mode {
        case add
        case edit
    }

    let mode: Mode
    let session: Session?
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var id: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var endDepositGame = Date()
    @State private var commission: Double = 20
    @State private var depositFee: Double = 2
    @State private var commissionType: Session.FeeType = .relative
    @State private var depositFeeType: Session.FeeType = .fixed

    init(mode: Mode, session: Session?, viewModel: SessionViewModel) {
        self.mode = mode
        self.session = session
        self.viewModel = viewModel

        if let session = session {
            _id = State(initialValue: session.id)
            _startDate = State(initialValue: session.startDate)
            _endDate = State(initialValue: session.endDate)
            _endDepositGame = State(initialValue: session.endDepositGame)
            _commission = State(initialValue: Double(session.commission))
            _depositFee = State(initialValue: Double(session.depositFee))
            _commissionType = State(initialValue: Session.FeeType(rawValue: session.commissionType) ?? .relative)
            _depositFeeType = State(initialValue: Session.FeeType(rawValue: session.depositFeeType) ?? .fixed)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Informations de base") {
                    TextField("ID", text: $id)
                    DatePicker("Date de début", selection: $startDate)
                    DatePicker("Date de fin", selection: $endDate)
                    DatePicker("Fin des dépôts", selection: $endDepositGame)
                }

                Section("Paramètres financiers") {
                    Picker("Type de commission", selection: $commissionType) {
                        Text("Relative (%)").tag(Session.FeeType.relative)
                        Text("Fixed (€)").tag(Session.FeeType.fixed)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Stepper(commissionType == .relative ? "Commission: \(commission, specifier: "%.1f")%" : "Commission: \(commission, specifier: "%.2f")€",
                            value: $commission,
                            in: commissionType == .relative ? 0...100 : 0...1000,
                            step: commissionType == .relative ? 0.5 : 1.0)

                    Picker("Type de frais de dépôt", selection: $depositFeeType) {
                        Text("Relative (%)").tag(Session.FeeType.relative)
                        Text("Fixed (€)").tag(Session.FeeType.fixed)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Stepper(depositFeeType == .relative ? "Frais de dépôt: \(depositFee, specifier: "%.1f")%" : "Frais de dépôt: \(depositFee, specifier: "%.2f")€",
                            value: $depositFee,
                            in: depositFeeType == .relative ? 0...100 : 0...1000,
                            step: depositFeeType == .relative ? 0.5 : 1.0)
                }
            }
            .navigationTitle(mode == .add ? "Nouvelle session" : "Modifier session")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(mode == .add ? "Ajouter" : "Sauvegarder") {
                        let newSession = Session(
                            _id: session?._id ?? "",
                            id: id,
                            startDate: startDate,
                            endDate: endDate,
                            endDepositGame: endDepositGame,
                            commissionType: commissionType.rawValue,
                            commission: Int(commission),
                            depositFeeType: depositFeeType.rawValue,
                            depositFee: Int(depositFee),
                            __v: session?.__v ?? 0
                        )

                        if mode == .add {
                            viewModel.addSession(newSession)
                        } else {
                            viewModel.updateSession(newSession)
                        }
                        dismiss()
                    }
                    .disabled(id.isEmpty)
                }
            }
        }
    }
}


struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
