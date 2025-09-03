import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool isPassword;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final Color borderColor;
  final Color textColor;
  final TextEditingController? controller;
  final VoidCallback? onTapOverride;
  final Icon? suffixOverrideIcon;
  final Icon? prefixIcon;
  final bool? isNumber;

  /// 👇 New props for customization
  final String? Function(String?)? customValidator;
  final TextInputType? keyboardTypeOverride;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final double borderRadius;
  final bool autoValidate;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.isPassword = false,
    this.isDropdown = false,
    this.dropdownItems,
    this.borderColor = const Color(0xFFCCCCCC),
    this.textColor = Colors.black,
    this.controller,
    this.onTapOverride,
    this.suffixOverrideIcon,
    this.prefixIcon,
    this.isNumber,
    this.customValidator,
    this.keyboardTypeOverride,
    this.labelStyle,
    this.hintStyle,
    this.borderRadius = 5,
    this.autoValidate = false,
    this.focusNode,
    this.nextFocusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() => _obscure = !_obscure);
  }

  void _showDropdownMenu() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height + 5,
        width: size.width,
        child: CompositedTransformFollower(
          offset: Offset(0, size.height + 5),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: widget.borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.dropdownItems!
                    .map((item) => ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(item, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    widget.controller?.text = item;
                    _removeDropdown();
                  },
                ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool get _isEmailField {
    final hint = widget.hint?.toLowerCase().replaceAll('-', '').trim() ?? '';
    return hint.contains("email");
  }

  String? _autoValidator(String? value) {
    if (widget.customValidator != null) {
      return widget.customValidator!(value);
    }

    if (value == null || value.trim().isEmpty) {
      return widget.hint != null ? '${widget.hint} is required' : "Required";
    }

    if (_isEmailField) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{1,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Enter a valid email address';
      }
    }

    if (widget.hint?.toLowerCase().contains('password') ?? false) {
      if (value.length < 8) return 'Password must be at least 8 characters';
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Include an uppercase letter';
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'Include a lowercase letter';
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include a number';
      if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
        return 'Include a special character';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? TextEditingController();

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: widget.labelStyle ??
                  const TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 6),
          ],
          // Text Field
          TextFormField(
            controller: controller,
            keyboardType: widget.keyboardTypeOverride ??
                (widget.isNumber == true
                    ? TextInputType.number
                    : _isEmailField
                    ? TextInputType.emailAddress
                    : TextInputType.text),
            textInputAction: widget.nextFocusNode != null
                ? TextInputAction.next
                : TextInputAction.done,
            focusNode: widget.focusNode,
            onFieldSubmitted: (_) {
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            },
            readOnly: widget.isDropdown || widget.onTapOverride != null,
            obscureText: widget.isPassword ? _obscure : false,
            validator: _autoValidator,
            autovalidateMode: widget.autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,

            style: TextStyle(
              color: controller.text.isNotEmpty
                  ? AppColor.white
                  : widget.textColor,
            ),

            onChanged: (_) => setState(() {}),

            onTap: widget.onTapOverride ??
                (widget.isDropdown
                    ? () {
                  if (_overlayEntry == null) {
                    _showDropdownMenu();
                  } else {
                    _removeDropdown();
                  }
                }
                    : null),

            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle ??
                  TextStyle(
                    color: AppColor.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
              prefixIcon: widget.prefixIcon,
              prefixIconColor: AppColor.white,
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.white,
                ),
                onPressed: _toggleVisibility,
              )
                  : widget.isDropdown
                  ? const Icon(
                Icons.arrow_drop_down_outlined,
                color: AppColor.white,
              )
                  : widget.onTapOverride != null
                  ? widget.suffixOverrideIcon ??
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColor.white,
                  )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.borderColor, width: 2),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.red, width: 1),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColor.red, width: 1),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
