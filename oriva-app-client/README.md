# Oriva — App Mobile Client

Marketplace mobile premium. Vitrine cliente de l'écosystème Oriva.

## 🎨 Design

- **Couleurs** : Noir profond (#080808) + Or (#C9A96E) + Crème (#F5F0E8)
- **Typographie** : Cormorant Garamond (titres) + DM Sans (texte)
- **Style** : Luxe africain, épuré, spacieux

## 🏗️ Stack

- **Flutter** 3.24+ avec `flutter_riverpod` (state), `go_router` (nav)
- **Supabase** (auth, DB, storage) partagé avec `oriva-web-seller`
- **Déploiement** : Vercel Web (MVP) → App Store + Play Store (Phase 3)

## 🚀 Développement local

```bash
flutter pub get
flutter run -d chrome        # Web
flutter run -d ios           # iOS simulator
flutter run -d android       # Android emulator
```

## 📦 Structure

```
lib/
├── main.dart                    # Entry point
├── core/
│   ├── theme/app_theme.dart     # Design tokens Oriva
│   ├── supabase/                # Client Supabase
│   └── router/                  # go_router config
├── features/
│   ├── onboarding/              # 3 slides d'accueil
│   ├── auth/                    # Login + Signup
│   ├── home/                    # Vitrine + bottom nav
│   ├── product/                 # Page détail produit
│   ├── cart/                    # Panier
│   ├── checkout/                # Paiement (Orange Money)
│   └── profile/                 # Compte client
└── shared/                      # Widgets réutilisables
```

## 🔐 Sécurité

- Variables d'env via `.env` (ignoré par Git) + `--dart-define` en production
- RLS Supabase appliqué côté DB (aucune donnée sensible exposée)
- Politique de sécurité : client n'accède qu'à ses propres commandes

## 🌐 Déploiement Vercel

Le fichier `vercel.json` configure automatiquement :
- Clonage du Flutter SDK
- Build web release
- Passage des variables d'env via `--dart-define`

Variables à configurer sur Vercel :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## 📱 Phase 3 — Publication stores

- iOS : Xcode + compte Apple Developer (99$/an)
- Android : Android Studio + compte Play Store (25$ une fois)
