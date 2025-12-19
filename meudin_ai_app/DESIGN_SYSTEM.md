# 🎨 Design System - Meudin App

## 📐 Tipografia

### Fonte Principal
**Inter** - Moderna, limpa e altamente legível

### Hierarquia de Texto

| Elemento | Tamanho | Weight | Letter Spacing | Uso |
|----------|---------|--------|----------------|-----|
| **Logo** | 40px | 700 (Bold) | -1.2 | Marca principal |
| **H1 (Títulos)** | 32px | 700 (Bold) | -0.8 | Títulos de página |
| **H2 (Subtítulos)** | 16px | 400 (Regular) | 0.2 | Subtítulos |
| **Body** | 16px | 500 (Medium) | 0 | Texto de campos |
| **Label** | 15px | 400 (Regular) | 0 | Labels de campos |
| **Caption** | 16px | 400 (Regular) | 0.5 | Taglines |
| **Link** | 15px | 600 (SemiBold) | 0 | Links e CTAs |
| **Small** | 14px | 400 (Regular) | 0 | Textos secundários |

### Pesos de Fonte (Font Weights)

```dart
FontWeight.w400  // Regular - Textos normais, labels
FontWeight.w500  // Medium - Texto de input
FontWeight.w600  // SemiBold - Links, botões secundários
FontWeight.w700  // Bold - Títulos, logo, botões principais
```

---

## 🎨 Campos de Texto (Text Fields)

### Especificações

```dart
TextFormField(
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Styles.primaryTextColor,
  ),
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 18,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.grey[200],
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Styles.primaryColor,
        width: 2,
      ),
    ),
  ),
)
```

### Estados

| Estado | Background | Border | Border Width |
|--------|------------|--------|--------------|
| **Default** | `grey[50]` | `grey[200]` | 1px |
| **Focused** | `grey[50]` | `primaryColor` | 2px |
| **Error** | `grey[50]` | `red[300]` | 1px |
| **Error Focused** | `grey[50]` | `red` | 2px |

### Características

- ✅ **Bordas arredondadas**: 16px
- ✅ **Background suave**: grey[50]
- ✅ **Padding generoso**: 20px horizontal, 18px vertical
- ✅ **Transição suave**: Border muda de cor ao focar
- ✅ **Sem borda padrão**: BorderSide.none no estado default
- ✅ **Label flutuante**: Animação automática

---

## 🎯 Botões

### Botão Principal (Primary Button)

```dart
ElevatedButton(
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
)
```

**Especificações:**
- Altura: 56px
- Border radius: 16px
- Elevation: 0 (flat)
- Texto: Maiúsculas, bold, letter-spacing 1.2

---

## 🎨 Paleta de Cores

### Cores Principais

```dart
primaryColor: #AC6CFF       // Roxo vibrante
primaryColorLight: #D6B7FF  // Roxo claro
primaryTextColor: #212121   // Texto principal
```

### Cores de Texto

| Uso | Cor | Código |
|-----|-----|--------|
| **Títulos** | Quase preto | `#212121` |
| **Subtítulos** | Cinza médio | `grey[500]` |
| **Labels** | Cinza | `grey[600]` |
| **Hints** | Cinza claro | `grey[400]` |
| **Links** | Roxo primário | `#AC6CFF` |

### Cores de Background

| Elemento | Cor |
|----------|-----|
| **Scaffold** | `Colors.white` |
| **Campos** | `grey[50]` |
| **Bordas** | `grey[200]` |

---

## 📏 Espaçamento

### Sistema de Espaçamento (8px base)

```dart
4px   // Extra pequeno
8px   // Pequeno
12px  // Pequeno-médio
16px  // Médio
20px  // Médio-grande
24px  // Grande
32px  // Extra grande
40px  // Extra extra grande
48px  // Seção
64px  // Entre seções principais
```

### Aplicação na Tela de Login

```dart
// Entre logo e título
SizedBox(height: 64)

// Entre título e subtítulo
SizedBox(height: 12)

// Entre subtítulo e formulário
SizedBox(height: 48)

// Entre campos
SizedBox(height: 20)

// Entre formulário e botão
SizedBox(height: 32)

// Padding lateral
EdgeInsets.symmetric(horizontal: 32)
```

---

## 🎭 Animações

### Logo (Fade In + Slide Up)

```dart
TweenAnimationBuilder(
  tween: Tween<double>(begin: 0, end: 1),
  duration: Duration(milliseconds: 600),
  curve: Curves.easeOut,
  builder: (context, double value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: child,
      ),
    );
  },
)
```

**Características:**
- Duração: 600ms
- Curva: easeOut
- Efeito: Fade in + slide up 20px

---

## 🎨 Componentes

### Logo com Ícone

```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Styles.primaryColor,
        Styles.primaryColorLight,
      ],
    ),
  ),
  child: Icon(
    Icons.account_balance_wallet_rounded,
    size: 56,
    color: Colors.white,
  ),
)
```

### Logo Texto (com Gradiente)

```dart
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [
      Styles.primaryColor,
      Styles.primaryColorLight,
    ],
  ).createShader(bounds),
  child: Text(
    'Meudin',
    style: GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -1.2,
    ),
  ),
)
```

---

## 📱 Responsividade

### Breakpoints

```dart
// Mobile (padrão)
horizontal: 32px

// Tablet (>600px)
horizontal: 64px

// Desktop (>1200px)
maxWidth: 480px
```

### Scroll

```dart
SingleChildScrollView(
  physics: BouncingScrollPhysics(),
  // ...
)
```

---

## ✨ Princípios de Design

### 1. Minimalismo
- Fundo branco limpo
- Sem elementos desnecessários
- Foco no conteúdo

### 2. Hierarquia Visual Clara
- Tamanhos de fonte variados
- Pesos de fonte apropriados
- Espaçamento generoso

### 3. Modernidade
- Bordas arredondadas (16px)
- Campos com background suave
- Gradientes sutis
- Animações suaves

### 4. Consistência
- Sistema de espaçamento baseado em 8px
- Paleta de cores definida
- Tipografia uniforme
- Componentes reutilizáveis

### 5. Acessibilidade
- Contraste adequado (WCAG AA)
- Tamanhos de fonte legíveis (≥14px)
- Áreas de toque ≥48px
- Labels claros

---

## 🎯 Checklist de Implementação

### Tipografia
- [x] Fonte Inter implementada
- [x] Hierarquia de tamanhos definida
- [x] Pesos de fonte consistentes
- [x] Letter spacing ajustado
- [x] Line height otimizado

### Campos de Texto
- [x] Bordas arredondadas (16px)
- [x] Background suave (grey[50])
- [x] Padding generoso
- [x] Estados visuais claros
- [x] Transições suaves

### Cores
- [x] Paleta definida
- [x] Cores de texto consistentes
- [x] Gradientes aplicados
- [x] Contraste adequado

### Espaçamento
- [x] Sistema baseado em 8px
- [x] Espaçamento consistente
- [x] Respiração adequada
- [x] Padding uniforme

### Animações
- [x] Animação de entrada do logo
- [x] Transições suaves
- [x] Scroll com bounce
- [x] Feedback visual

---

## 📊 Comparação Antes vs Depois

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Campos** | Quadrados, sem background | Arredondados, background suave |
| **Bordas** | Retas, 0px | Arredondadas, 16px |
| **Fonte** | Poppins | Inter (mais moderna) |
| **Pesos** | Bold genérico | Sistema de pesos (400-700) |
| **Espaçamento** | Inconsistente | Sistema baseado em 8px |
| **Tipografia** | Desarmônica | Hierarquia clara |
| **Visual** | Pesado | Leve e clean |

---

## 🚀 Próximos Passos

### Aplicar em outras telas
1. Sign Up
2. Recover Password
3. Home
4. New Transaction
5. Profile

### Componentes a criar
- [ ] JoyButton (botão customizado)
- [ ] JoyCard (card padrão)
- [ ] JoyAppBar (app bar customizada)
- [ ] JoyBottomSheet (bottom sheet)
- [ ] JoyDialog (diálogo)

### Melhorias futuras
- [ ] Dark mode
- [ ] Animações de transição
- [ ] Micro-interações
- [ ] Skeleton loaders
- [ ] Toast messages

---

## 📚 Referências

### Fontes
- **Inter**: https://fonts.google.com/specimen/Inter
- Família moderna e versátil
- Ótima legibilidade em telas
- Suporta múltiplos pesos

### Inspirações
- Material Design 3
- iOS Human Interface Guidelines
- Fintech apps modernos
- Dribbble/Behance trends

---

## 💡 Dicas de Uso

### Para desenvolvedores

1. **Use o sistema de espaçamento**
   ```dart
   // Bom
   SizedBox(height: 16)
   
   // Evite
   SizedBox(height: 15)
   ```

2. **Mantenha consistência de pesos**
   ```dart
   // Títulos
   FontWeight.w700
   
   // Corpo
   FontWeight.w500
   
   // Labels
   FontWeight.w400
   ```

3. **Reutilize componentes**
   ```dart
   // Use JoyTextFormField
   JoyTextFormField(...)
   
   // Não crie TextFormField do zero
   ```

4. **Siga a paleta de cores**
   ```dart
   // Use
   Styles.primaryColor
   
   // Não use
   Color(0xFF...)
   ```

---

## ✅ Resultado Final

O design system agora está:
- ✨ Moderno e clean
- 🎨 Visualmente harmonioso
- 📱 Responsivo
- ♿ Acessível
- 🔧 Manutenível
- 📐 Consistente

**Pronto para escalar para todo o app!** 🚀

