import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/themes/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _labelAnimation;

  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    _focusNode = widget.focusNode ?? FocusNode();
    _setupAnimations();
    _setupFocusListener();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: Colors.white24,
      end: AppTheme.goldColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        if (widget.controller?.text.isEmpty ?? true) {
          _animationController.reverse();
        }
      }
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查错误状态变化
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    if (hasError != _hasError) {
      setState(() {
        _hasError = hasError;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主输入框
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _isFocused ? 2 : 1,
                ),
                color: Colors.white.withOpacity(0.05),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.goldColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                textCapitalization: widget.textCapitalization,
                textInputAction: widget.textInputAction,
                onEditingComplete: widget.onEditingComplete,
                onFieldSubmitted: widget.onFieldSubmitted,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _getIconColor(),
                          size: 20.sp,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  labelStyle: TextStyle(
                    color: _getLabelColor(),
                    fontSize: _getLabelSize(),
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white38,
                    fontSize: 16.sp,
                  ),
                  counterText: '',
                ),
              ),
            );
          },
        ),
        
        // 错误提示
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 16.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBorderColor() {
    if (_hasError) {
      return AppTheme.errorColor;
    }
    
    if (_isFocused) {
      return _borderColorAnimation.value ?? AppTheme.goldColor;
    }
    
    return Colors.white24;
  }

  Color _getIconColor() {
    if (_hasError) {
      return AppTheme.errorColor;
    }
    
    if (_isFocused) {
      return AppTheme.goldColor;
    }
    
    return Colors.white54;
  }

  Color _getLabelColor() {
    if (_hasError) {
      return AppTheme.errorColor;
    }
    
    if (_isFocused) {
      return AppTheme.goldColor;
    }
    
    return Colors.white70;
  }

  double _getLabelSize() {
    return _isFocused || (widget.controller?.text.isNotEmpty ?? false)
        ? 12.sp
        : 16.sp;
  }
}

// 搜索输入框
class SearchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
    
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? '搜索...',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white54,
            size: 20.sp,
          ),
          suffixIcon: _showClearButton
              ? GestureDetector(
                  onTap: _clearText,
                  child: Icon(
                    Icons.clear,
                    color: Colors.white54,
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        onChanged: (value) => widget.onChanged?.call(value),
      ),
    );
  }
}

// 数字输入框
class NumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int?>? onChanged;
  final FormFieldValidator<String>? validator;

  const NumberTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.minValue,
    this.maxValue,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxValue != null)
          _NumberRangeFormatter(minValue ?? 0, maxValue!),
      ],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '请输入数字';
            }
            
            final number = int.tryParse(value);
            if (number == null) {
              return '请输入有效数字';
            }
            
            if (minValue != null && number < minValue!) {
              return '数字不能小于$minValue';
            }
            
            if (maxValue != null && number > maxValue!) {
              return '数字不能大于$maxValue';
            }
            
            return null;
          },
      onChanged: (value) {
        final number = int.tryParse(value);
        onChanged?.call(number);
      },
    );
  }
}

class _NumberRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _NumberRangeFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text);
    if (number == null) {
      return oldValue;
    }

    if (number < min || number > max) {
      return oldValue;
    }

    return newValue;
  }
}