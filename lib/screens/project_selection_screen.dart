import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:archify_app/main.dart';
import 'package:archify_app/models/project.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/screens/upload_status_screen.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/screen_badge.dart';

class ProjectSelectionScreen extends StatefulWidget {
  final int previewId;
  final int? nodesCount;
  final int? edgesCount;

  final ApiService? apiService;

  const ProjectSelectionScreen({
    super.key,
    required this.previewId,
    this.nodesCount,
    this.edgesCount,
    this.apiService,
  });

  @override
  State<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends State<ProjectSelectionScreen> {
  late final ApiService _apiService = widget.apiService ?? ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Project> _projects = [];
  Project? _selectedProject;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> get _filteredProjects {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _projects;
    return _projects
        .where((p) => p.title.toLowerCase().contains(query))
        .toList();
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
    setState(() => _isUploading = true);

    final result = await _apiService.commitPhotoPreview(
      widget.previewId,
      projectId: _selectedProject?.id,
    );

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    setState(() => _isUploading = false);

    if (result['success'] == true && result['photo_id'] is int) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => UploadStatusScreen(
            photoId: result['photo_id'] as int,
            projectId: _selectedProject?.id,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opslaan mislukt: ${result['message']}')),
    );
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
          const Text(
            'Waar wil je deze schets opslaan?',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _onUpload,
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
                      : 'Uploaden naar Mijn Schetsen',
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
                'Je hebt nog geen projecten.\nDeze foto wordt opgeslagen in Mijn Schetsen.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredProjects;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSearchField(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildDestinationTile(
                title: 'Mijn Schetsen',
                icon: LucideIcons.folder,
                isSelected: _selectedProject == null,
                onTap: () => setState(() => _selectedProject = null),
              ),
              const SizedBox(height: 16),
              const Text('Projecten', style: AppTextStyles.body),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                _buildNoMatches()
              else
                ...filtered.map((project) {
                  final isSelected = _selectedProject?.id == project.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildDestinationTile(
                      title: project.title,
                      icon: LucideIcons.folderOpen,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedProject = project),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.grey),
    );

    return TextField(
      controller: _searchController,
      enabled: !_isUploading,
      onChanged: (value) => setState(() => _searchQuery = value),
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.magenta,
      style: const TextStyle(color: AppColors.white, fontSize: 16),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Zoek een project',
        hintStyle: const TextStyle(color: AppColors.grey),
        prefixIcon: const Icon(
          LucideIcons.search,
          color: AppColors.grey,
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  color: AppColors.grey,
                  size: 20,
                ),
                tooltip: 'Zoekopdracht wissen',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        enabledBorder: border,
        border: border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.magenta, width: 2),
        ),
      ),
    );
  }

  Widget _buildNoMatches() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Geen projecten gevonden',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    );
  }

  Widget _buildDestinationTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isUploading ? null : onTap,
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
              isSelected ? LucideIcons.checkCircle2 : icon,
              color: isSelected ? AppColors.magenta : AppColors.grey,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.grey,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
