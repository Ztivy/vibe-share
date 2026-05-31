import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vibe_share/firebase/storage_supabase.dart';
import 'package:vibe_share/models/usuario_model.dart';
import 'package:vibe_share/providers/auth_provider.dart';
import 'package:vibe_share/utils/strings_app.dart';
import 'package:vibe_share/utils/theme_app.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.usuarioActual;
        if (user == null) return const SizedBox.shrink();
        return _PerfilView(user: user, auth: auth);
      },
    );
  }
}

// ── Vista principal ───────────────────────────────────────────────────────────

class _PerfilView extends StatelessWidget {
  final UsuarioModel user;
  final AuthProvider auth;

  const _PerfilView({required this.user, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.nombre.isNotEmpty ? user.nombre : 'Perfil'),
        actions: [
          IconButton(
            icon: Icon(
              auth.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: auth.toggleTheme,
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: ThemeApp.spacingLg),
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          _AvatarSection(user: user, auth: auth),

          const SizedBox(height: ThemeApp.spacingLg),

          // ── Stats ────────────────────────────────────────────────────
          _StatsRow(user: user),

          const Divider(height: ThemeApp.spacingXl),

          // ── Géneros de interés ────────────────────────────────────────
          _GenerosSection(user: user, auth: auth),

          const Divider(height: ThemeApp.spacingXl),

          // ── Bio ───────────────────────────────────────────────────────
          _BioSection(user: user, auth: auth),

          const Divider(height: ThemeApp.spacingXl),

          // ── Premium badge ─────────────────────────────────────────────
          if (user.esPremium) const _PremiumBadge(),

          const SizedBox(height: ThemeApp.spacingXl),

          // ── Logout ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeApp.spacingXl,
            ),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: Text(StringsApp.profileLogout),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                final confirm = await _showLogoutDialog(context);
                if (confirm == true) auth.logout();
              },
            ),
          ),

          const SizedBox(height: ThemeApp.spacingXxl),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              StringsApp.profileLogout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _AvatarSection ────────────────────────────────────────────────────────────

class _AvatarSection extends StatefulWidget {
  final UsuarioModel user;
  final AuthProvider auth;

  const _AvatarSection({required this.user, required this.auth});

  @override
  State<_AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends State<_AvatarSection> {
  final _storage = StorageSupabase();
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _cambiarAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final file = File(picked.path);
      final url = await _storage.subirAvatar(widget.user.uid, file);
      if (url != null) {
        await widget.auth.actualizarPerfil({'avatarUrl': url});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.user.avatarUrl;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar circular
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _uploading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _AvatarFallback(),
                            )
                          : const _AvatarFallback(),
                ),
              ),

              // Botón de cámara
              GestureDetector(
                onTap: _uploading ? null : _cambiarAvatar,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeApp.spacingMd),

          // Nombre
          Text(
            widget.user.nombre,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: ThemeApp.spacingXs),
          Text(
            widget.user.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.15),
      child: const Icon(
        Icons.person_rounded,
        size: 52,
        color: AppColors.primary,
      ),
    );
  }
}

// ── _StatsRow ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UsuarioModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeApp.spacingXl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: StringsApp.profileFriends,
            value: '${user.amigos.length}',
          ),
          _divider(),
          _StatItem(
            label: StringsApp.profilePosts,
            value: '—',
          ),
          _divider(),
          _StatItem(
            label: StringsApp.profileGenres,
            value: '${user.generosInteres.length}',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 36,
        width: 1,
        color: AppColors.border,
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ── _GenerosSection ───────────────────────────────────────────────────────────

class _GenerosSection extends StatefulWidget {
  final UsuarioModel user;
  final AuthProvider auth;

  const _GenerosSection({required this.user, required this.auth});

  @override
  State<_GenerosSection> createState() => _GenerosSectionState();
}

class _GenerosSectionState extends State<_GenerosSection> {
  late List<String> _seleccionados;
  bool _editando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _seleccionados = List.from(widget.user.generosInteres);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await widget.auth.actualizarPerfil({'generosInteres': _seleccionados});
    if (mounted) setState(() {
      _guardando = false;
      _editando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeApp.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: ThemeApp.spacingSm),
                child: Text(
                  StringsApp.profileGenres,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _editando ? Icons.close_rounded : Icons.edit_rounded,
                  size: 18,
                ),
                label: Text(_editando ? 'Cancelar' : 'Editar'),
                onPressed: () {
                  setState(() {
                    if (_editando) {
                      // Revertir
                      _seleccionados = List.from(widget.user.generosInteres);
                    }
                    _editando = !_editando;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: ThemeApp.spacingSm),

          // Chips
          Wrap(
            spacing: ThemeApp.spacingSm,
            runSpacing: ThemeApp.spacingSm,
            children: StringsApp.generosMusicales.map((genero) {
              final seleccionado = _seleccionados.contains(genero);
              if (!_editando && !seleccionado) return const SizedBox.shrink();

              return FilterChip(
                label: Text(genero),
                selected: seleccionado,
                onSelected: _editando
                    ? (val) {
                        setState(() {
                          if (val) {
                            _seleccionados.add(genero);
                          } else {
                            _seleccionados.remove(genero);
                          }
                        });
                      }
                    : null,
              );
            }).toList(),
          ),

          // Botón guardar
          if (_editando) ...[
            const SizedBox(height: ThemeApp.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar géneros'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _BioSection ───────────────────────────────────────────────────────────────

class _BioSection extends StatefulWidget {
  final UsuarioModel user;
  final AuthProvider auth;

  const _BioSection({required this.user, required this.auth});

  @override
  State<_BioSection> createState() => _BioSectionState();
}

class _BioSectionState extends State<_BioSection> {
  late TextEditingController _ctrl;
  bool _editando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await widget.auth.actualizarPerfil({'bio': _ctrl.text.trim()});
    if (mounted) setState(() {
      _guardando = false;
      _editando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeApp.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: ThemeApp.spacingSm),
                child: Text(
                  'Bio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _editando ? Icons.close_rounded : Icons.edit_rounded,
                  size: 18,
                ),
                label: Text(_editando ? 'Cancelar' : 'Editar'),
                onPressed: () {
                  setState(() {
                    if (_editando) _ctrl.text = widget.user.bio;
                    _editando = !_editando;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: ThemeApp.spacingSm),

          if (_editando)
            TextField(
              controller: _ctrl,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: 'Cuéntanos algo sobre ti y tu música...',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: ThemeApp.spacingSm),
              child: Text(
                widget.user.bio.isNotEmpty
                    ? widget.user.bio
                    : 'Sin bio aún. ¡Cuéntanos sobre ti!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          if (_editando) ...[
            const SizedBox(height: ThemeApp.spacingSm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar bio'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _PremiumBadge ─────────────────────────────────────────────────────────────

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeApp.spacingMd),
      child: Container(
        padding: const EdgeInsets.all(ThemeApp.spacingMd),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD166), Color(0xFFFF9A3C)],
          ),
          borderRadius: BorderRadius.circular(ThemeApp.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.white, size: 28),
            const SizedBox(width: ThemeApp.spacingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringsApp.profilePremium,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Miembro activo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}