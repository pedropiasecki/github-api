import 'dart:convert';
import 'dart:typed_data';

import 'package:apk_auth/components/my_texfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/my_button.dart';
import '../service/location_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
    const ProfilePage({super.key});

    @override
    State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
    final user = FirebaseAuth.instance.currentUser!;
    final locationService = LocationService();

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();

    Uint8List? avatarBytes;
    String? city;
    String? country;
    bool loading = true;
    bool busy = false;
    bool locating = false;

    DocumentReference<Map<String, dynamic>> get profileDoc =>
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    bool get canChangePassword =>
        user.providerData.any((p) => p.providerId == 'password');

    @override
    void initState() {
        super.initState();
        loadProfile();
    }

    @override
    void dispose() {
        nameController.dispose();
        descriptionController.dispose();
        currentPasswordController.dispose();
        newPasswordController.dispose();
        confirmController.dispose();
        super.dispose();
    }

    void showAlert(String message) {
        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                content: Text(message),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                    ),
                ],
            ),
        );
    }

    Future<void> loadProfile() async {
        nameController.text = user.displayName ?? '';
        try {
            final data = (await profileDoc.get()).data();
            if (!mounted) return;
            descriptionController.text = data?['description'] ?? '';
            city = data?['city'];
            country = data?['country'];
            final avatar = data?['avatarBase64'];
            if (avatar is String && avatar.isNotEmpty) {
                avatarBytes = base64Decode(avatar);
            }
        } catch (_) {
            if (mounted) showAlert('Não foi possível carregar seu perfil.');
        }
        if (mounted) setState(() => loading = false);
    }

    Future<void> pickAvatar() async {
        final file = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            // Reduz a imagem para caber folgado em um documento do Firestore
            maxWidth: 400,
            maxHeight: 400,
            imageQuality: 75,
        );
        if (file == null) return;
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        setState(() => avatarBytes = bytes);
    }

    Future<void> findLocation() async {
        if (busy || locating) return;
        setState(() => locating = true);
        try {
            // Explica a finalidade antes de pedir a permissão.
            final allowed = await locationService.permissaoConcedida();
            if (!mounted) return;
            if (!allowed) {
                final accepted = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                        title: const Text('Permissão de localização'),
                        content: const Text(
                            'O aplicativo consulta sua cidade ou país na BigDataCloud usando sua localização. Deseja permitir?'),
                        actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Agora não'),
                            ),
                            FilledButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('Permitir'),
                            ),
                        ],
                    ),
                );
                if (!mounted || accepted != true) return;
            }

            final location = await locationService.obterLocalizacao();
            if (!mounted) return;
            setState(() {
                city = location['city'];
                country = location['country'];
            });
        } catch (e) {
            if (!mounted) return;
            showAlert(e.toString().replaceFirst('Exception: ', ''));
        } finally {
            if (mounted) setState(() => locating = false);
        }
    }

    void showAvatarOptions() {
        showModalBottomSheet(
            context: context,
            builder: (sheetContext) => SafeArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        ListTile(
                            leading: const Icon(Icons.photo_library_outlined),
                            title: const Text('Escolher da galeria'),
                            onTap: () {
                                Navigator.pop(sheetContext);
                                pickAvatar();
                            },
                        ),
                        if (avatarBytes != null)
                            ListTile(
                                leading: const Icon(Icons.delete_outline),
                                title: const Text('Remover foto'),
                                onTap: () {
                                    Navigator.pop(sheetContext);
                                    setState(() => avatarBytes = null);
                                },
                            ),
                    ],
                ),
            ),
        );
    }

    Future<void> saveProfile() async {
        final name = nameController.text.trim();
        if (name.isEmpty) {
            showAlert('O nome não pode ficar vazio.');
            return;
        }

        setState(() => busy = true);
        try {
            await user.updateDisplayName(name);
            await profileDoc.set({
                'description': descriptionController.text.trim(),
                if (city != null) 'city': city,
                if (country != null) 'country': country,
                'avatarBase64': avatarBytes == null
                    ? FieldValue.delete()
                    : base64Encode(avatarBytes!),
                'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            if (!mounted) return;
            showAlert('Perfil atualizado!');
        } on FirebaseException catch (e) {
            if (!mounted) return;
            showAlert(switch (e.code) {
                'permission-denied' =>
                    'Sem permissão para salvar. Confira as regras do Firestore.',
                _ => 'Não foi possível salvar o perfil. Tente novamente.',
            });
        } finally {
            if (mounted) setState(() => busy = false);
        }
    }

    Future<void> changePassword() async {
        final current = currentPasswordController.text;
        final next = newPasswordController.text;

        if (current.isEmpty || next.isEmpty || confirmController.text.isEmpty) {
            showAlert('Preencha os três campos de senha.');
            return;
        }
        if (next != confirmController.text) {
            showAlert('As senhas não conferem!');
            return;
        }

        setState(() => busy = true);
        try {
            final credential = EmailAuthProvider.credential(
                email: user.email!,
                password: current,
            );
            await user.reauthenticateWithCredential(credential);
            await user.updatePassword(next);

            currentPasswordController.clear();
            newPasswordController.clear();
            confirmController.clear();

            if (!mounted) return;
            showAlert('Senha alterada com sucesso!');
        } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            showAlert(switch (e.code) {
                'wrong-password' ||
                'invalid-credential' => 'Senha atual incorreta.',
                'weak-password' => 'Escolha uma senha mais forte.',
                'too-many-requests' =>
                    'Muitas tentativas. Aguarde um pouco e tente de novo.',
                _ => 'Não foi possível alterar a senha. Tente novamente.',
            });
        } finally {
            if (mounted) setState(() => busy = false);
        }
    }

    Widget sectionTitle(String text) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 12),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    text,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                    ),
                ),
            ),
        );
    }

    Widget buildAvatar() {
        final name = nameController.text.trim();
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        return GestureDetector(
            onTap: busy ? null : showAvatarOptions,
            child: Stack(
                children: [
                    CircleAvatar(
                        radius: 56,
                        backgroundColor: AppTheme.card,
                        backgroundImage:
                            avatarBytes != null ? MemoryImage(avatarBytes!) : null,
                        child: avatarBytes == null
                            ? Text(initial, style: const TextStyle(fontSize: 40))
                            : null,
                    ),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.accent,
                            child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Meu perfil')),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            children: [
                                buildAvatar(),
                                const SizedBox(height: 12),
                                Text(
                                    user.email ?? '',
                                    style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 25),
                                sectionTitle('Dados do perfil'),
                                MyTextField(
                                    controller: nameController,
                                    hintText: 'Nome completo',
                                    icon: Icons.person_outline,
                                    keyboardType: TextInputType.name,
                                    textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 15),
                                MyTextField(
                                    controller: descriptionController,
                                    hintText: 'Descrição',
                                    icon: Icons.notes,
                                    maxLines: 4,
                                    maxLength: 200,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                ),
                                const SizedBox(height: 15),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text(city != null && city!.isNotEmpty
                                                ? 'Cidade: $city'
                                                : country != null && country!.isNotEmpty
                                                    ? 'País: $country'
                                                    : 'Localização não informada'),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                    onPressed: busy || locating ? null : findLocation,
                                                    icon: const Icon(Icons.my_location),
                                                    label: Text(locating
                                                        ? 'Buscando localização...'
                                                        : 'Buscar minha localização'),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 10),
                                MyButton(
                                    onTap: busy || locating ? null : saveProfile,
                                    text: 'Salvar alterações',
                                    icon: Icons.save,
                                ),
                                if (canChangePassword) ...[
                                    const SizedBox(height: 35),
                                    sectionTitle('Alterar senha'),
                                    MyTextField(
                                        controller: currentPasswordController,
                                        hintText: 'Senha atual',
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                    ),
                                    const SizedBox(height: 15),
                                    MyTextField(
                                        controller: newPasswordController,
                                        hintText: 'Nova senha',
                                        icon: Icons.lock_reset,
                                        isPassword: true,
                                    ),
                                    const SizedBox(height: 15),
                                    MyTextField(
                                        controller: confirmController,
                                        hintText: 'Confirmar nova senha',
                                        icon: Icons.lock_reset,
                                        isPassword: true,
                                    ),
                                    const SizedBox(height: 25),
                                    MyButton(
                                        onTap: busy ? null : changePassword,
                                        text: 'Alterar senha',
                                        icon: Icons.key,
                                    ),
                                ],
                            ],
                        ),
                    ),
                ),
        );
    }
}
