import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/forgot_password_provider.dart';
import '../providers/forgot_password_state.dart';
import '../widgets/auth_ambient_rings.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/auth_hero_header.dart';
import '../widgets/auth_otp_boxes.dart';
import '../widgets/auth_security_badge.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/forgot_password_step_indicator.dart';
import '../widgets/forgot_password_success_view.dart';

/// Màn hình Quên mật khẩu Finora (SOLARN Design System 1:1 theo device-preview)
/// Hỗ trợ luồng 3 bước: Nhập Email -> Xác thực OTP (đếm ngược 30s) -> Đặt lại mật khẩu
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  // 6 controllers & focus nodes cho ô nhập OTP 6 số
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Quản lý đếm ngược 30 giây thời gian thực cho mã OTP
  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _getOtpString() {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  void _clearOtpInputs() {
    for (final c in _otpControllers) {
      c.clear();
    }
    if (_otpFocusNodes.isNotEmpty) {
      _otpFocusNodes[0].requestFocus();
    }
  }

  // ── Xử lý Bước 1: Gửi mã OTP về Email ──────────────────────────────────
  Future<void> _handleSendOtp() async {
    context.hideKeyboard();
    if (!_emailFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success =
        await ref.read(forgotPasswordProvider.notifier).sendOtp(email);

    if (success && mounted) {
      final expiresIn = ref.read(forgotPasswordProvider).expiresIn;
      AppToast.success(
        context,
        'Mã xác thực OTP đã được gửi về email của bạn (hiệu lực $expiresIn giây)',
      );
      _clearOtpInputs();
      _startCountdown(expiresIn);
    }
  }

  // ── Xử lý Gửi lại mã OTP ───────────────────────────────────────────────
  Future<void> _handleResendOtp() async {
    context.hideKeyboard();
    final success =
        await ref.read(forgotPasswordProvider.notifier).resendOtp();

    if (success && mounted) {
      final expiresIn = ref.read(forgotPasswordProvider).expiresIn;
      AppToast.success(
        context,
        'Đã gửi lại mã xác thực mới (hiệu lực $expiresIn giây)',
      );
      _clearOtpInputs();
      _startCountdown(expiresIn);
    }
  }

  // ── Xử lý Bước 2: Xác thực mã OTP ──────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    context.hideKeyboard();
    final otp = _getOtpString();

    if (otp.length < 6) {
      AppToast.error(context, 'Vui lòng nhập đủ 6 chữ số mã xác thực');
      return;
    }

    if (_secondsRemaining <= 0) {
      AppToast.error(
        context,
        'Mã OTP đã hết hạn sau 30 giây. Vui lòng bấm "Gửi lại mã"',
      );
      return;
    }

    final success =
        await ref.read(forgotPasswordProvider.notifier).verifyOtp(otp);

    if (success && mounted) {
      _countdownTimer?.cancel();
      AppToast.success(context, 'Xác thực OTP thành công! Vui lòng đặt mật khẩu mới');
    }
  }

  // ── Xử lý Bước 3: Đặt lại mật khẩu mới ─────────────────────────────────
  Future<void> _handleResetPassword() async {
    context.hideKeyboard();
    if (!_passwordFormKey.currentState!.validate()) return;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass != confirmPass) {
      AppToast.error(context, 'Mật khẩu xác nhận không khớp');
      return;
    }

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .resetPassword(newPass);

    if (success && mounted) {
      AppToast.success(context, 'Đặt lại mật khẩu thành công!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(forgotPasswordProvider);

    IconData heroIcon;
    String heroSubtitle;
    switch (state.step) {
      case ForgotPasswordStep.email:
        heroIcon = Icons.lock_reset_rounded;
        heroSubtitle = 'Khôi phục quyền truy cập ví tài chính';
        break;
      case ForgotPasswordStep.otp:
        heroIcon = Icons.mark_email_read_rounded;
        heroSubtitle = 'Xác thực mã bảo mật hiệu lực 30 giây';
        break;
      case ForgotPasswordStep.newPassword:
        heroIcon = Icons.vpn_key_rounded;
        heroSubtitle = 'Thiết lập mật khẩu bảo mật mới';
        break;
      case ForgotPasswordStep.success:
        heroIcon = Icons.verified_user_rounded;
        heroSubtitle = 'Bảo vệ tài khoản thành công';
        break;
    }

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

          // ── Main Content Layer ────────────────────────────────────────────
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
                                        if (state.step ==
                                            ForgotPasswordStep.otp) {
                                          ref
                                              .read(forgotPasswordProvider
                                                  .notifier)
                                              .changeEmail();
                                          _countdownTimer?.cancel();
                                        } else if (context.canPop()) {
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
                                      'KHÔI PHỤC MẬT KHẨU',
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 6),
                                child: AuthHeroHeader(
                                  icon: heroIcon,
                                  title: 'Finora ID',
                                  subtitle: heroSubtitle,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 3. Card Bottom Sheet Layer
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Progress Indicator 3 bước
                                      ForgotPasswordStepIndicator(
                                        currentStep: state.step,
                                      ),
                                      const SizedBox(height: 20),

                                      // Banner lỗi API nếu có
                                      if (state.errorMessage != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 11),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF3B1D1D)
                                                : const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFF87171)
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                color: Color(0xFFEF4444),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  state.errorMessage!,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFFFCA5A5)
                                                        : const Color(
                                                            0xFFB91C1C),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],

                                      // Nội dung chính thay đổi theo từng bước
                                      if (state.step ==
                                          ForgotPasswordStep.email)
                                        _buildEmailStep(isDark, state.isLoading)
                                      else if (state.step ==
                                          ForgotPasswordStep.otp)
                                        _buildOtpStep(isDark, state)
                                      else if (state.step ==
                                          ForgotPasswordStep.newPassword)
                                        _buildNewPasswordStep(
                                            isDark, state.isLoading)
                                      else
                                        ForgotPasswordSuccessView(
                                          onLoginPressed: () =>
                                              context.go(RoutePaths.login),
                                        ),

                                      const Spacer(),
                                      const SizedBox(height: 20),

                                      // 4. Security Badge
                                      const AuthSecurityBadge(),

                                      const SizedBox(height: 14),

                                      // Link quay lại Đăng nhập
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (context.canPop()) {
                                              context.pop();
                                            } else {
                                              context.go(RoutePaths.login);
                                            }
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppColors.darkMuted
                                                    : AppColors.lightMuted,
                                              ),
                                              children: const [
                                                TextSpan(
                                                    text: 'Nhớ lại mật khẩu? '),
                                                TextSpan(
                                                  text: 'Đăng nhập ngay',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w800,
                                                  ),
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

  // ── BƯỚC 1: Nhập Email ──────────────────────────────────────────────────
  Widget _buildEmailStep(bool isDark, bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quên mật khẩu?',
            style: GoogleFonts.outfit(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhập địa chỉ email đăng ký để nhận mã OTP 6 số (hiệu lực 30 giây).',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 22),
          AuthTextField(
            label: 'Địa chỉ Email',
            controller: _emailController,
            prefixIcon: Icons.alternate_email_rounded,
            hintText: 'example@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: AuthValidators.validateEmail,
            onFieldSubmitted: (_) => _handleSendOtp(),
          ),
          const SizedBox(height: 24),
          AuthGradientButton(
            label: 'GỬI MÃ XÁC THỰC',
            icon: Icons.send_rounded,
            isLoading: isLoading,
            onPressed: _handleSendOtp,
          ),
        ],
      ),
    );
  }

  // ── BƯỚC 2: Nhập OTP 6 số & Đếm ngược 30 giây ───────────────────────────
  Widget _buildOtpStep(bool isDark, ForgotPasswordState state) {
    final isExpired = _secondsRemaining <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nhập mã xác thực',
          style: GoogleFonts.outfit(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color:
                isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Mã xác nhận 6 số đã được gửi tới email của bạn.',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        const SizedBox(height: 14),

        // Hộp hiển thị Email đã mask
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.14)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.maskedEmail.isNotEmpty
                      ? state.maskedEmail
                      : state.email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkForeground
                        : const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(forgotPasswordProvider.notifier).changeEmail();
                  _countdownTimer?.cancel();
                },
                child: Text(
                  'Thay đổi',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── ĐỒNG HỒ ĐẾM NGƯỢC 30 GIÂY THỜI GIAN THỰC ──────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isExpired
                ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                : const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: isExpired
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              Text(
                isExpired
                    ? 'Mã xác thực đã hết hạn sau 30 giây'
                    : 'Mã còn hiệu lực trong: ${_secondsRemaining}s',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isExpired
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 6 Ô NHẬP OTP RIÊNG BIỆT ────────────────────────────────────────
        AuthOtpBoxes(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
          onCompleted: _handleVerifyOtp,
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 20),

        // Nút Xác thực OTP
        AuthGradientButton(
          label: 'XÁC THỰC MÃ OTP',
          icon: Icons.check_circle_outline_rounded,
          isLoading: state.isLoading,
          onPressed: _handleVerifyOtp,
        ),

        const SizedBox(height: 14),

        // Nút Gửi lại mã OTP
        Center(
          child: TextButton.icon(
            onPressed: (isExpired && !state.isLoading) ? _handleResendOtp : null,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              isExpired
                  ? 'Gửi lại mã OTP ngay'
                  : 'Gửi lại mã (sau ${_secondsRemaining}s)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── BƯỚC 3: Đặt lại mật khẩu mới ────────────────────────────────────────
  Widget _buildNewPasswordStep(bool isDark, bool isLoading) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tạo mật khẩu mới',
            style: GoogleFonts.outfit(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mật khẩu mới phải có tối thiểu 6 ký tự để bảo vệ tài khoản của bạn.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            ),
          ),
          const SizedBox(height: 20),

          // Mật khẩu mới
          AuthTextField(
            label: 'Mật khẩu mới',
            controller: _newPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            hintText: 'Tối thiểu 6 ký tự',
            obscureText: !_isNewPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isNewPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onPressed: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),
            validator: AuthValidators.validatePassword,
          ),

          const SizedBox(height: 14),

          // Nhập lại mật khẩu mới
          AuthTextField(
            label: 'Xác nhận mật khẩu mới',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_reset_rounded,
            hintText: 'Nhập lại mật khẩu mới',
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (val != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleResetPassword(),
          ),

          const SizedBox(height: 24),

          // Nút cập nhật mật khẩu
          AuthGradientButton(
            label: 'LƯU MẬT KHẨU MỚI',
            icon: Icons.save_rounded,
            isLoading: isLoading,
            onPressed: _handleResetPassword,
          ),
        ],
      ),
    );
  }
}
