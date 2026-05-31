class StringsApp {
  StringsApp._();

  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'VibeShare';
  static const String appTagline = 'Comparte lo que suena en tu alma';

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboarding1Title = 'Tu música, tu identidad';
  static const String onboarding1Body =
      'Comparte los fragmentos que definen quién eres. '
      'Cada canción cuenta una historia.';

  static const String onboarding2Title = 'Conecta con tu tribu';
  static const String onboarding2Body =
      'Agrega amigos, sigue géneros y descubre '
      'personas que vibran igual que tú.';

  static const String onboarding3Title = 'El feed que mereces';
  static const String onboarding3Body =
      'Ve publicaciones de amigos y sugerencias '
      'personalizadas según tus géneros favoritos.';

  static const String onboardingSkip = 'Saltar';
  static const String onboardingNext = 'Siguiente';
  static const String onboardingGetStarted = 'Comenzar';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Bienvenido a VibeShare';
  static const String loginSubtitle =
      'Inicia sesión para compartir tu música favorita';
  static const String loginGoogle = 'Continuar con Google';
  static const String loginError = 'Error al iniciar sesión. Intenta de nuevo.';

  // ── Dashboard / Nav ──────────────────────────────────────────────────────
  static const String navFeed = 'Feed';
  static const String navDiscover = 'Descubrir';
  static const String navPublish = 'Publicar';
  static const String navFriends = 'Amigos';
  static const String navProfile = 'Perfil';

  // ── Feed ─────────────────────────────────────────────────────────────────
  static const String feedTitle = 'VibeShare';
  static const String feedEmpty = 'Aún no hay publicaciones. ¡Sé el primero!';
  static const String feedLikes = 'Me gusta';
  static const String feedComments = 'Comentarios';

  // ── Nueva Publicación ────────────────────────────────────────────────────
  static const String newPostTitle = 'Nueva Publicación';
  static const String newPostHint = '¿Qué canción quieres compartir hoy?';
  static const String newPostSongName = 'Nombre de la canción';
  static const String newPostArtist = 'Artista';
  static const String newPostGenre = 'Género';
  static const String newPostAddMedia = 'Agregar fragmento';
  static const String newPostPublish = 'Publicar';
  static const String newPostSuccess = '¡Publicación creada!';
  static const String newPostError = 'Error al publicar. Intenta de nuevo.';

  // ── Perfil ───────────────────────────────────────────────────────────────
  static const String profileEdit = 'Editar perfil';
  static const String profileFriends = 'Amigos';
  static const String profilePosts = 'Publicaciones';
  static const String profileGenres = 'Géneros favoritos';
  static const String profilePremium = 'Premium';
  static const String profileLogout = 'Cerrar sesión';
  static const String profileChangeAvatar = 'Cambiar foto';

  // ── Amigos ───────────────────────────────────────────────────────────────
  static const String friendsTitle = 'Amigos';
  static const String friendsSearch = 'Buscar usuarios...';
  static const String friendsAdd = 'Agregar';
  static const String friendsPending = 'Pendiente';
  static const String friendsAccept = 'Aceptar';
  static const String friendsDecline = 'Rechazar';
  static const String friendsRequests = 'Solicitudes';
  static const String friendsSuggestions = 'Sugerencias por género';

  // ── Géneros ──────────────────────────────────────────────────────────────
  static const List<String> generosMusicales = [
    'Pop',
    'Rock',
    'Hip-Hop',
    'Reggaeton',
    'Electrónica',
    'Jazz',
    'Clásica',
    'R&B',
    'Indie',
    'Metal',
    'Cumbia',
    'Salsa',
    'K-Pop',
    'Country',
    'Blues',
    'Folk',
    'Trap',
    'Bachata',
    'Reggae',
    'Funk',
  ];

  // ── Monetización ─────────────────────────────────────────────────────────
  static const String premiumTitle = 'VibeShare Premium';
  static const String premiumSubtitle = 'Lleva tu experiencia al siguiente nivel';
  static const String premiumPrice = '\$59/mes';
  static const String premiumCTA = 'Suscribirme ahora';
  static const List<String> premiumBenefits = [
    'Sin anuncios',
    'Fragmentos de hasta 60 segundos',
    'Estadísticas de tus publicaciones',
    'Badge exclusivo en tu perfil',
    'Acceso anticipado a nuevas funciones',
  ];

  // ── Notificaciones ───────────────────────────────────────────────────────
  static const String notifLike = 'le dio Me gusta a tu publicación';
  static const String notifFriendReq = 'te envió una solicitud de amistad';
  static const String notifNewPost = 'compartió una nueva canción';

  // ── Errores generales ────────────────────────────────────────────────────
  static const String errorGeneral = 'Algo salió mal. Intenta de nuevo.';
  static const String errorNoInternet = 'Sin conexión a internet.';
  static const String errorPermission = 'Permisos insuficientes.';

  // ── Assets ───────────────────────────────────────────────────────────────
  static const String defaultAvatar =
      'https://ui-avatars.com/api/?background=6C63FF&color=fff&name=VS';
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1Asset = 'assets/onboarding/slide1.png';
  static const String onboarding2Asset = 'assets/onboarding/slide2.png';
  static const String onboarding3Asset = 'assets/onboarding/slide3.png';

  // ── SharedPreferences Keys ───────────────────────────────────────────────
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefThemeMode = 'theme_mode';
}
