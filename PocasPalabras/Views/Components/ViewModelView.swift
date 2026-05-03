import SwiftUI

/// A generic container that lazily initializes a ViewModel on appear
/// and passes it to the content closure once ready.
///
/// Usage:
/// ```
/// ViewModelView {
///     MyViewModel(modelContext: modelContext)
/// } content: { viewModel in
///     Text(viewModel.title)
/// }
/// ```
struct ViewModelView<VM: Observable, Content: View>: View {
    private let create: @MainActor () -> VM
    private let content: (VM) -> Content

    @State private var viewModel: VM?

    init(
        _ create: @escaping @MainActor () -> VM,
        @ViewBuilder content: @escaping (VM) -> Content
    ) {
        self.create = create
        self.content = content
    }

    var body: some View {
        if let viewModel {
            content(viewModel)
        } else {
            Color.clear.onAppear {
                viewModel = create()
            }
        }
    }
}
