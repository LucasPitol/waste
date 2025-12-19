import 'package:get/get.dart';

class FAQPageController extends GetxController {
  int? expandedIndex;

  final List<Map<String, String>> faqItems = [
    {
      'question': 'O que é o Meudin?',
      'answer': 'O Meudin é um aplicativo de gestão financeira pessoal e compartilhada, focado em simplicidade e controle real de gastos. Ele permite que você entenda para onde o dinheiro está indo e tome decisões melhores sem complexidade excessiva.',
    },
    {
      'question': 'Como criar uma carteira?',
      'answer': 'Para criar uma carteira, toque no botão "+" na tela inicial e selecione "Nova carteira". Você pode criar carteiras para diferentes contextos, como Pessoal, Empresa, Viagem ou Projeto.',
    },
    {
      'question': 'Como compartilhar uma carteira?',
      'answer': 'Acesse a carteira que deseja compartilhar, vá em "Membros" e toque em "Adicionar membro". Você pode convidar outros usuários por email. Eles receberão permissões de membro e poderão visualizar e adicionar transações.',
    },
    {
      'question': 'Como adicionar uma transação?',
      'answer': 'Toque no botão "+" na tela inicial e escolha "Nova receita" ou "Novo gasto". Preencha o valor, descrição, categoria e data. A transação será registrada na carteira selecionada.',
    },
    {
      'question': 'O que são categorias?',
      'answer': 'Categorias ajudam a organizar seus gastos por tipo (alimentação, transporte, saúde, etc.). Elas são usadas para análise, gráficos e relatórios, permitindo que você entenda melhor seus padrões de gasto.',
    },
    {
      'question': 'Como filtrar transações por período?',
      'answer': 'Na tela inicial, toque na data exibida ao lado do saldo (ex: "dezembro de 2025") para abrir o seletor de mês/ano. Você pode visualizar o balanço e transações de qualquer período.',
    },
    {
      'question': 'Qual a diferença entre os planos?',
      'answer': 'O plano Iniciante (gratuito) permite uma carteira e funcionalidades básicas. O plano Premium oferece múltiplas carteiras, mais membros por carteira, filtros avançados, exportação de dados e relatórios detalhados.',
    },
    {
      'question': 'Meus dados estão seguros?',
      'answer': 'Sim. Todos os dados financeiros são criptografados e armazenados com segurança. Utilizamos Supabase com PostgreSQL para garantir a proteção das suas informações. Nunca compartilhamos seus dados pessoais.',
    },
    {
      'question': 'Como alterar minha senha?',
      'answer': 'Acesse "Perfil" > "Configurações" e selecione a opção para alterar senha. Você receberá um email com instruções para redefinir sua senha.',
    },
    {
      'question': 'Posso exportar meus dados?',
      'answer': 'A exportação de dados está disponível no plano Premium. Você pode exportar suas transações em formato PDF ou Excel para análise externa ou backup.',
    },
  ];

  void toggleExpanded(int index) {
    if (expandedIndex == index) {
      expandedIndex = null;
    } else {
      expandedIndex = index;
    }
    update();
  }
}
