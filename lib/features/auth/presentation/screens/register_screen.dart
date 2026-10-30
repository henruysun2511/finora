import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/register_input.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/register_form_provider.dart';
import '../widgets/auth_ambient_rings.dart';
import '../widgets/auth_hero_header.dart';
import '../widgets/auth_security_badge.dart';
import '../widgets/auth_text_field.dart';

/// Màn hình Đăng ký tài khoản Finora
/// Chuẩn kiến trúc feature products (FormState, FormProvider, Validators)
/// và thị giác 1:1 theo device-preview (SOLARN Design System)
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final input = RegisterInput(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final user = await ref.read(registerFormProvider.notifier).submit(input);

    if (user != null && mounted) {
      AppToast.success(
        context,
        'Đăng ký tài khoản thành công! Chào mừng ${user.name}',
      );
      // Điều hướng người dùng khám phá Onboarding hoặc Trang chủ
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutePaths.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.watch(registerFormProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF004D9A),
      body: Stack(
        children: [
          // ── Gradient Brand Background ─────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF073A84),
                    AppColors.primary,
                    Color(0xFF2E8FF2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Ambient Glowing Rings ─────────────────────────────────────────
          const AuthAmbientRings(),

          // ── Main Content Layer (Chống tràn khi mở bàn phím) ──────────────
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Top Navigation Bar
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(RoutePaths.login);
                                        }
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                              .withValues(alpha: 0.18),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.28),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'TẠO TÀI KHOẢN',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                    const SizedBox(width: 36),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // 2. Auth Hero & Brand Mark
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 6),
                                child: AuthHeroHeader(
                                  icon: Icons.person_add_rounded,
                                  title: 'Finora ID',
                                  subtitle:
                                      'Gia nhập hệ sinh thái 7 trợ lý AI',
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 3. Registration Bottom Sheet
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurface
                                        : Colors.white,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(32)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                            alpha: isDark ? 0.4 : 0.14),
                                        blurRadius: 30,
                                        offset: const Offset(0, -10),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                      24, 26, 24, 30),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Đăng ký tài khoản',
                                          style: GoogleFonts.outfit(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.6,
                                            color: isDark
                                                ? AppColors.darkForeground
                                                : AppColors.lightForeground,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Bắt đầu hành trình quản lý tài chính thông minh',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppColors.darkMuted
                                                : AppColors.lightMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        // Banner hiển thị lỗi API (theo chuẩn product_form_screen.dart)
                                        if (formState.errorMessage != null)
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.danger
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.danger
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline_rounded,
                                                  color: AppColors.danger,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    formState.errorMessage!,
                                                    style: GoogleFonts.inter(
                                                      color: AppColors.danger,
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Trường 1: Họ và tên
                                        AuthTextField(
                                          label: 'Họ và tên',
                                          controller: _fullNameController,
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          hintText: 'Nguyễn Văn A',
                                          textCapitalization:
                                              TextCapitalization.words,
                                          validator:
                                              AuthValidators.validateFullName,
                                        ),
                                        const SizedBox(height: 12),

                                        // Trường 2: Tên đăng nhập (Bắt buộc theo chuẩn NestJS Backend)
                                        AuthTextField(
                                          label: 'Tên đăng nhập',
                                          controller: _usernameController,
                                          prefixIcon:
                                              Icons.alternate_email_rounded,
                                          hintText: 'nguyenvana',
                                          validator:
                                              AuthValidators.validateUsername,
                                        ),
                                        const SizedBox(height: 12),

                                        // Trường 3: Email
                                        AuthTextField(
                                          label: 'Email',
                                          controller: _emailController,
                                          prefixIcon: Icons.mail_outline_rounded,
                                          hintText: 'name@example.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator:
                                              AuthValidators.validateEmail,
                                        ),
                                        const SizedBox(height: 12),

                                        // Trường 4: Mật khẩu
                                        AuthTextField(
                                          label: 'Mật khẩu',
                                          controller: _passwordController,
                                          prefixIcon: Icons.lock_outline_rounded,
                                          hintText: 'Tối thiểu 6 ký tự',
                                          obscureText: !_isPasswordVisible,
                                          validator:
                                              AuthValidators.validatePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 20,
                                              color: isDark
                                                  ? AppColors.darkMuted
                                                  : AppColors.lightMuted,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          onFieldSubmitted: (_) =>
                                              _handleRegister(),
                                        ),
                                        const SizedBox(height: 14),

                                        // Huy hiệu bảo mật AES-256
                                        const AuthSecurityBadge(),
                                        const SizedBox(height: 18),

                                        // Nút Đăng ký tài khoản Gradient
                                        Container(
                                          height: 52,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                Color(0xFF0058A8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.38),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: formState.isSubmitting
                                                  ? null
                                                  : _handleRegister,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Center(
                                                child: formState.isSubmitting
                                                    ? const SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Đăng ký tài khoản',
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              letterSpacing:
                                                                  -0.2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          const Icon(
                                                            Icons
                                                                .arrow_outward_rounded,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 18),

                                        // Footer: Link quay lại Đăng nhập
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Đã có tài khoản? ',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.darkMuted
                                                    : AppColors.lightMuted,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (context.canPop()) {
                                                  context.pop();
                                                } else {
                                                  context.pushReplacementNamed(
                                                      RouteNames.login);
                                                }
                                              },
                                              child: Text(
                                                'Đăng nhập ngay',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
