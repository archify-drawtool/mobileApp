import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/main.dart';
import 'package:archify_app/models/project.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/photo_service.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/screen_badge.dart';

class ProjectSelectionScreen extends StatefulWidget {
  final String photoPath;

  const ProjectSelectionScreen({super.key, required this.photoPath});

  @override
  State<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends State<ProjectSelectionScreen> {
  final ApiService _apiService = ApiService();
  final PhotoService _photoService = PhotoService();
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getProjects();

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success']) {
      final projects = result['projects'] as List<Project>;
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] as String;
        _isLoading = false;
      });
    }
  }

  Future<void> _onUpload() async {
    if (_selectedProject == null) return;

    setState(() => _isUploading = true);

    final fixedPath = await _photoService.fixOrientation(widget.photoPath);
    final result = await _apiService.uploadPhoto(
      fixedPath,
      projectId: _selectedProject!.id,
    );

    await _photoService.cleanupFixedPhoto(fixedPath);

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success']
              ? 'Foto is succesvol geüpload'
              : 'Upload mislukt: ${result['message']}',
        ),
      ),
    );

    if (result['success']) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArchifyLogo(),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
          onPressed: _isUploading ? null : () => Navigator.pop(context),
        ),
        actions: [const ScreenBadge(label: 'PROJECT')],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          const Text('Selecteer een project', style: AppTextStyles.body),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedProject != null && !_isUploading
                    ? _onUpload
                    : null,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(LucideIcons.upload, size: 18),
                label: Text(
                  _isUploading
                      ? 'Uploaden...'
                      : _selectedProject != null
                      ? 'Uploaden naar "${_selectedProject!.title}"'
                      : 'Selecteer een project',
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.magenta),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff, color: AppColors.grey, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _loadProjects,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_projects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.folderOpen, color: AppColors.grey, size: 48),
              SizedBox(height: 16),
              Text(
                'Je hebt nog geen projecten.\nMaak eerst een project aan in de webapp.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _projects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final project = _projects[index];
        final isSelected = _selectedProject?.id == project.id;

        return GestureDetector(
          onTap: _isUploading
              ? null
              : () => setState(() => _selectedProject = project),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.magenta : AppColors.grey,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.magentaLight : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  color: isSelected ? AppColors.magenta : AppColors.grey,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    project.title,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.grey,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
