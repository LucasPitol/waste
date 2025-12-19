class AdBanner {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? deepLink; // Link interno do app
  final String? externalLink; // Link externo
  final String sponsorLabel; // Ex: "Patrocinado", "Parceria"

  AdBanner({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.deepLink,
    this.externalLink,
    this.sponsorLabel = 'Patrocinado',
  });

  // Banner padrão para demonstração
  static AdBanner? getDefaultBanner() {
    return AdBanner(
      id: 'default',
      title: 'Organize seus investimentos',
      description: 'Ferramentas profissionais para planejamento financeiro',
      sponsorLabel: 'Parceria',
    );
  }
}
