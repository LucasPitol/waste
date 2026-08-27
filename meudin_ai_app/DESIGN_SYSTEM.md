# Design System — Meudin App

Documentação alinhada à implementação em `lib/ui/`, `lib/services/theme_service.dart` e telas do app.

---

## Arquitetura

### Arquivos centrais

| Arquivo | Responsabilidade |
|---------|------------------|
| `lib/ui/styles.dart` | Cores, temas light/dark, decorações reutilizáveis |
| `lib/ui/app_typography.dart` | Fonte Inter (Android/Web) ou fonte do sistema (iOS) |
| `lib/ui/joy_ui.dart` | Barrel export dos componentes Joy |
| `lib/services/theme_service.dart` | Persistência e troca de tema (GetX) |
| `lib/main.dart` | Aplica `ThemeMode` via `GetMaterialApp` |

### Componentes Joy (exportados em `joy_ui.dart`)

```
JoyElevatedButton    JoyTextFormField    JoyLoadingBlock
JoyTextButton        JoyText             JoyLogo
JoyModal             JoyGeometrics
```

Componentes de assinatura em `lib/ui/subscription/`:

```
PremiumBadge    PremiumFeatureWrapper    ManageSubscriptionButton
```

Ícones em `lib/ui/app_icons.dart` — wrapper `AppIcon` sobre Phosphor Icons.

---

## Temas (Light / Dark / Sistema)

Gerenciado por `ThemeService`. Preferência salva em secure storage via `LocalStorageService`.

| Modo | Valor salvo | Label na UI |
|------|-------------|-------------|
| Escuro (padrão) | `dark` | Escuro |
| Claro | `light` | Claro |
| Sistema | `system` | Sistema |

**Padrão para novos usuários:** tema escuro (`ThemeMode.dark`).

Seleção disponível em **Perfil → Tema**.

```dart
// main.dart
GetMaterialApp(
  theme: Styles.mainTheme,
  darkTheme: Styles.darkTheme,
  themeMode: themeService.themeMode,
)
```

### Status bar e navigation bar

Ajustados dinamicamente em `main.dart` conforme o brightness ativo:
- Tema escuro: ícones claros, nav bar `#121212`
- Tema claro: ícones escuros, nav bar branca

---

## Tipografia

### Fonte

| Plataforma | Fonte |
|------------|-------|
| Android / Web | **Inter** via `GoogleFonts.inter` |
| iOS | Fonte do sistema (SF Pro) |

Use `AppTypography.textTheme()` e `AppTypography.textStyle()` — não instancie `GoogleFonts.inter` diretamente nas telas.

### Hierarquia de referência

Valores usados nas telas principais (login, perfil, cards):

| Elemento | Tamanho | Weight | Letter Spacing | Onde |
|----------|---------|--------|----------------|------|
| Logo (`JoyLogo`) | 40px | 700 | -1.2 | App bar, login |
| H1 (títulos de página) | 32px | 700 | -0.8 | Login (`sign_in_page`) |
| H1 (`JoyText.h1`) | 20px | bold | — | Modais, avisos |
| Subtítulo | 16px | 400 | 0.2 | Login, seções |
| Body / input | 16px | 500 | 0 | `JoyTextFormField` |
| Label | 15px | 400 | 0 | Labels de campo |
| Caption / tagline | 16px | 400 | 0.5 | Login |
| Link / CTA secundário | 15px | 600 | 0 | Links, `JoyTextButton` |
| Texto secundário | 14px | 400–500 | 0 | `JoyText.secundaryText` |
| KPI label | 12px | 400 | — | `KpiCardsWidget` |
| KPI valor | 14px | 600 | — | `KpiCardsWidget` |
| Badge premium | 11px | 600 | — | `PremiumBadge` |

### Pesos de fonte

```dart
FontWeight.w400  // Regular — labels, textos secundários
FontWeight.w500  // Medium — inputs, corpo
FontWeight.w600  // SemiBold — links, valores KPI
FontWeight.w700  // Bold — títulos, CTAs principais
```

---

## Paleta de cores

### Tokens em `Styles`

```dart
primaryColor:        #AC6CFF   // Roxo vibrante
primaryColorLight:   #D6B7FF   // Roxo claro
primaryTextColor:    #212121   // Texto principal (tema claro)
whiteColor:          #FFFFFF
whiteConfortColor:   #FAFAFA   // Scaffold tema claro
grey:                #BDBDBD   // Ícones/texto desabilitado
selectionTextColor:  #E1F5FE   // Seleção de texto (tema claro)
```

### Tema claro (`Styles.mainTheme`)

| Token | Valor |
|-------|-------|
| Scaffold | `#FAFAFA` (`whiteConfortColor`) |
| Surface / cards | `#FFFFFF` |
| Texto principal | `#212121` |
| Primary | `#AC6CFF` |

### Tema escuro (`Styles.darkTheme`)

| Token | Valor |
|-------|-------|
| Scaffold | `#121212` |
| Surface / cards | `#1E1E1E` |
| Texto principal | `#FFFFFF` |
| Texto secundário | `#FFFFFF` 70% / 60% |
| Primary | `#AC6CFF` |
| Seleção de texto | `primaryColor` 30% opacidade |

### Cores semânticas (uso pontual)

| Uso | Cor |
|-----|-----|
| Receita / positivo | `Colors.green` |
| Despesa / negativo | `Colors.red` |
| Neutro / saldo zero | `Colors.grey` |
| Erro em campos | `Colors.red[300]` / `Colors.red` (focused) |

### Cores de texto por contexto

| Uso | Tema claro | Tema escuro |
|-----|------------|-------------|
| Títulos | `#212121` / `titleLarge` | `#FFFFFF` |
| Subtítulos | `grey[500]` / `bodyMedium` | `white70` |
| Labels | `grey[600]` | `grey[400]` |
| Hints | `grey[400]` | `grey[500]` |
| Links | `primaryColor` | `primaryColor` |

---

## Border radius

Tokens definidos em `Styles`:

```dart
sexyBorderRadius       // 16px — modais, campos, botões primários inline
rectangularBorderRadius // 5px  — JoyElevatedButton (legado)
cardDecoration         // 10px — cards com sombra
```

| Elemento | Radius |
|----------|--------|
| Text fields | 16px |
| Botão primário (login, CTAs inline) | 16px |
| `JoyElevatedButton` | 5px |
| Cards (KPI, `cardDecoration`) | 10px |
| Bottom sheets (`JoyModal`) | 20px (top) ou 16px |
| Logo PNG (login) | 28px (`ClipRRect`) |
| Skeleton shimmer | 4–6px |
| `PremiumBadge` | 4px |

---

## Campos de texto — `JoyTextFormField`

Componente padrão para formulários (login, cadastro, recuperação de senha, transações, etc.).

```dart
JoyTextFormField(
  controller: controller,
  labelText: 'Email',
  keyboardType: TextInputType.emailAddress,
)
```

### Especificações

- Fonte do input: 16px, `FontWeight.w500`
- Padding: 20px horizontal, 18px vertical
- `filled: true`, radius 16px
- Label flutuante com animação automática
- `floatingLabelStyle`: `primaryColor`, 16px, w500

### Estados (adaptados ao tema)

| Estado | Background (claro / escuro) | Border | Width |
|--------|----------------------------|--------|-------|
| Default | `grey[50]` / `surface` | `grey[200]` / `grey[700]` | 1px |
| Focused | idem | `primaryColor` | 2px |
| Error | idem | `red[300]` | 1px |
| Error focused | idem | `red` | 2px |

---

## Botões

### Botão primário (padrão recomendado)

Usado inline nas telas de auth e CTAs principais:

```dart
SizedBox(
  height: 56,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Styles.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Text(
      'ENTRAR',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  ),
)
```

| Propriedade | Valor |
|-------------|-------|
| Altura | 56px |
| Radius | 16px |
| Elevation | 0 |
| Texto | MAIÚSCULAS, bold, letter-spacing 1.2 |

### `JoyElevatedButton` (legado)

Componente existente com specs diferentes — **preferir o padrão inline acima** em telas novas:

| Propriedade | Valor |
|-------------|-------|
| Altura | 50px |
| Radius | 5px (`rectangularBorderRadius`) |
| Background padrão | `primaryTextColor` (#212121) |

### `JoyTextButton`

Links e ações secundárias — cor padrão `primaryColor`, fonte 14px bold.

---

## Texto — `JoyText`

```dart
JoyText('Texto padrão')           // 16px, w600, cor do tema
JoyText.h1('Título modal')        // 20px, bold
JoyText.secundaryText('Detalhe')  // 14px, w500, cinza adaptado ao tema
```

Respeita automaticamente `Theme.of(context)` quando `textColor` é o padrão (`primaryTextColor` ou `grey`).

---

## Logo — `JoyLogo`

Texto "Meudin" com gradiente roxo via `ShaderMask`:

```dart
const JoyLogo()  // 40px, w700, letterSpacing -1.2
```

Na tela de login, combina com ícone PNG:

```dart
Image.asset('assets/internal/icon.png', width: 124, height: 124)
// + JoyLogo + tagline
```

---

## Modais e bottom sheets — `JoyModal`

| Método | Uso |
|--------|-----|
| `errorBottomSheet` | Erros de formulário (layout compacto) |
| `bottomSheetError` | Erros com lista de bullets |
| `bottomSheetWarning` | Avisos |
| `limitReachedBottomSheet` | Limite de plano + CTA upgrade |
| `showJouBottomSheet` | Wrapper genérico |

Todos adaptam background e cores ao tema ativo (`surface` no escuro, `whiteColor` no claro).

`JoyGeometrics.horizontalBar()` — handle visual (88×8px, `grey[300]`) nos bottom sheets.

---

## Loading — `JoyLoadingBlock`

Overlay fullscreen com blur (`BackdropFilter`, sigma 10) e `CircularProgressIndicator` na cor `primaryColor`.

```dart
Stack(
  children: [
    /* conteúdo */,
    JoyLoadingBlock(controller.loading),
  ],
)
```

---

## Skeleton loaders

Padrão shimmer reutilizável em `wallet_vision_skeleton.dart`:

```dart
SkeletonLoader(width: 120, height: 16, borderRadius: BorderRadius.circular(4))
```

Cores adaptadas ao tema:
- Claro: base `grey[300]`, highlight `grey[100]`
- Escuro: base `grey[800]`, highlight `grey[700]`

Implementações existentes:
- `wallet_vision_skeleton.dart`
- `expense_category_chart_skeleton.dart`
- `monthly_income_expense_bar_chart_skeleton.dart`
- Skeleton inline em `KpiCardsWidget`

---

## Cards

Não há componente `JoyCard` — cards são construídos inline ou via `Styles.cardDecoration`:

```dart
// cardDecoration (Styles)
BoxDecoration(
  color: whiteColor,
  borderRadius: 10px,
  boxShadow: [grey[200], offset (0,2), blur 2],
)
```

Padrão KPI (`KpiCardsWidget`):
- Padding 16px, radius 10px
- Background: `whiteColor` (claro) / `surface` (escuro)
- Sombra sutil adaptada ao tema

---

## Ícones — `AppIcon`

Wrapper sobre **Phosphor Icons** com escala óptica (`opticalScale = 1.12`) para paridade visual.

```dart
AppIcon(AppIcons.solidCircleUser, size: 22, color: themeColor)
```

Catálogo de ícones em `AppIcons` (`lib/ui/app_icons.dart`).

---

## Assinatura (Premium)

| Componente | Descrição |
|------------|-----------|
| `PremiumBadge` | Badge roxo com ícone de estrela |
| `PremiumFeatureWrapper` | Envolve features bloqueadas |
| `ManageSubscriptionButton` | Ação de gerenciar assinatura |

Estilo: fundo `primaryColor` 8–12% opacidade, borda roxa sutil.

---

## Espaçamento

Sistema baseado em múltiplos de 4/8px (sem token centralizado — valores usados na prática):

```
4px   — micro (links próximos)
8px   — interno de cards/KPI
12px  — gap entre cards, subtítulo
16px  — padding interno de cards
20px  — padding horizontal de app bar, entre campos
24px  — seções internas
32px  — padding lateral (auth), entre form e botão
40px  — margem vertical (auth)
48px  — entre subtítulo e formulário
64px  — entre logo e título (referência login)
```

### Referência — tela de login (`sign_in_page.dart`)

```dart
padding horizontal: 32
logo → título:       24 (após animação)
título → subtítulo:  12
subtítulo → form:    48
entre campos:        20
form → botão:        32
botão → links:       32
```

---

## Animações

### Entrada do logo (login)

```dart
TweenAnimationBuilder(
  tween: Tween<double>(begin: 0, end: 1),
  duration: Duration(milliseconds: 600),
  curve: Curves.easeOut,
  // Fade in + slide up 20px
)
```

### Skeleton shimmer

`AnimationController` 1200ms, loop, gradiente deslizante.

### Scroll

`BouncingScrollPhysics()` nas telas de auth.

---

## App bars

Não há `JoyAppBar` genérico. Implementação atual:

- **Auth:** sem app bar
- **Home:** `HomeAppBar` — `JoyLogo` + ícone de perfil (`AppIcon`)
- **Demais telas:** `AppBar` padrão Flutter com cores do tema

---

## Feedback ao usuário

| Tipo | Implementação atual |
|------|---------------------|
| Erros de form | `JoyModal` bottom sheets |
| Loading | `JoyLoadingBlock` |
| Toasts / avisos rápidos | `Get.snackbar` / `SnackBar` (sem componente padronizado) |

---

## Responsividade

```dart
// Auth — padding lateral fixo
EdgeInsets.symmetric(horizontal: 32)

// Conteúdo principal — margem horizontal 20px (home, insights)
EdgeInsets.symmetric(horizontal: 20)

// Scroll
SingleChildScrollView(physics: BouncingScrollPhysics())
```

---

## Princípios de design

1. **Consistência** — reutilizar componentes Joy e tokens de `Styles`
2. **Suporte a tema** — sempre consultar `Theme.of(context)` para cores de superfície e texto
3. **Minimalismo** — fundo neutro, foco no conteúdo financeiro
4. **Hierarquia clara** — pesos e tamanhos distintos por função
5. **Acessibilidade** — fontes ≥ 11px, áreas de toque ≥ 48px, contraste adequado nos dois temas

---

## Guia para desenvolvedores

### 1. Use os componentes existentes

```dart
// ✅ Preferido
JoyTextFormField(...)
JoyText(...)
const JoyLogo()

// ❌ Evite recriar TextFormField do zero
```

### 2. Respeite o tema ativo

```dart
final theme = Theme.of(context);
final isDark = theme.brightness == Brightness.dark;
color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor
background: isDark ? theme.colorScheme.surface : Styles.whiteColor
```

### 3. Use tokens de cor

```dart
// ✅
Styles.primaryColor
Styles.primaryTextColor

// ❌
Color(0xFFAC6CFF)  // hardcoded
```

### 4. Tipografia via AppTypography

```dart
AppTypography.textStyle(fontSize: 16, fontWeight: FontWeight.w500)
```

### 5. Espaçamento em múltiplos de 4/8

```dart
SizedBox(height: 16)  // ✅
SizedBox(height: 15)  // ❌
```

---

## Pendências conhecidas

Itens ainda não padronizados na codebase:

- [ ] Unificar `JoyElevatedButton` com o padrão de botão primário (56px / 16px radius)
- [ ] Criar `JoyCard` reutilizável (hoje cards são inline)
- [ ] Criar `JoyAppBar` genérico
- [ ] Criar componente de toast/snackbar padronizado
- [ ] Documentar tokens de espaçamento como constantes (`AppSpacing`)
- [ ] Micro-interações e animações de transição entre telas

---

## Referências

- **Inter:** https://fonts.google.com/specimen/Inter
- **Phosphor Icons:** https://phosphoricons.com/
- **Material Design 3** — inspiração para elevation, radius e temas
