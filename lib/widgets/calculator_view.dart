import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:medimaster/constant/app_constant_colors.dart';

class CalculatorController extends GetxController {
  final display = '0'.obs;
  final currentInput = ''.obs;
  final equation = ''.obs;
  final firstOperand = 0.0.obs;
  final operator = ''.obs;
  final clearNext = false.obs;

  void updateDisplay(String value) {
    if (value == 'C') {
      display.value = '0';
      currentInput.value = '';
      equation.value = '';
      firstOperand.value = 0;
      operator.value = '';
      clearNext.value = false;
    } else if (value == '⌫') {
      // Character-by-character erasure of the equation
      if (equation.value.isNotEmpty) {
        // Special handling for equations that end with equals sign
        if (equation.value.endsWith(' =')) {
          // Remove the equals sign and space
          equation.value =
              equation.value.substring(0, equation.value.length - 2);

          // Reset the state to before calculation
          if (operator.value.isEmpty) {
            // Extract second operand from equation
            final parts = equation.value.split(' ');
            if (parts.length >= 3) {
              // Extract operation and operands
              final op = parts[parts.length - 2];
              final secondOpString = parts[parts.length - 1];
              final firstOpString = parts[parts.length - 3];

              // Restore operator
              operator.value = op;

              // Restore operands
              try {
                final secondOp = int.parse(secondOpString);
                final firstOp = double.parse(firstOpString);

                firstOperand.value = firstOp;
                currentInput.value = secondOpString;
                display.value = secondOpString;
                clearNext.value = false;
              } catch (e) {
                // If parsing fails, just keep current state
              }
            }
          }
          return;
        }

        // Special handling for equations that end with operators
        if (equation.value.endsWith(' + ') ||
            equation.value.endsWith(' - ') ||
            equation.value.endsWith(' × ') ||
            equation.value.endsWith(' ÷ ')) {
          // Remove the operator and spaces
          equation.value =
              equation.value.substring(0, equation.value.length - 3);
          operator.value = '';
          clearNext.value = false;

          // After removing operator, restore the first operand as current input
          try {
            final value =
                double.tryParse(equation.value.trim()) ?? firstOperand.value;
            currentInput.value = value.toString();
            if (currentInput.value.endsWith('.0')) {
              currentInput.value = currentInput.value
                  .substring(0, currentInput.value.length - 2);
            }
            display.value = currentInput.value;
          } catch (e) {
            currentInput.value = firstOperand.value.toString();
            if (currentInput.value.endsWith('.0')) {
              currentInput.value = currentInput.value
                  .substring(0, currentInput.value.length - 2);
            }
            display.value = currentInput.value;
          }
          return;
        }

        // If second operand is present in equation, handle its erasure
        final parts = equation.value.split(' ');
        if (parts.length >= 3 &&
            operator.value.isNotEmpty &&
            !equation.value.endsWith(' ')) {
          // We're editing the second operand
          if (equation.value.isNotEmpty) {
            // Remove the last character
            equation.value =
                equation.value.substring(0, equation.value.length - 1);

            // Update second operand in currentInput
            final newParts = equation.value.split(' ');
            if (newParts.length >= 3) {
              final secondOpString = newParts[newParts.length - 1];
              if (secondOpString.isNotEmpty) {
                currentInput.value = secondOpString;
                display.value = secondOpString;
              } else {
                // If all digits of second operand are erased
                currentInput.value = '0';
                display.value = '0';
                // Update equation to remove trailing space if any
                if (equation.value.endsWith(' ')) {
                  equation.value =
                      equation.value.substring(0, equation.value.length - 1);
                }
              }
            }
          }
          return;
        }

        // For a regular character in the equation (first operand), remove just the last character
        if (equation.value.isNotEmpty) {
          // Remove the last character
          equation.value =
              equation.value.substring(0, equation.value.length - 1);

          // Update the display and current input to match equation
          if (equation.value.isNotEmpty) {
            currentInput.value = equation.value;
            display.value = equation.value;
          } else {
            currentInput.value = '0';
            display.value = '0';
          }
          return;
        }
      }

      // If equation is empty or we've handled equation cases, deal with current input
      if (currentInput.value.length > 1) {
        currentInput.value =
            currentInput.value.substring(0, currentInput.value.length - 1);
        display.value = currentInput.value;
      } else if (currentInput.value.length == 1 && currentInput.value != "0") {
        currentInput.value = '0';
        display.value = '0';
      }
    } else if (value == '=') {
      if (operator.value.isNotEmpty && currentInput.value.isNotEmpty) {
        final secondOperand = int.parse(currentInput.value);
        double result = 0;

        equation.value = '${equation.value} $secondOperand =';

        switch (operator.value) {
          case '+':
            result = firstOperand.value + secondOperand;
            break;
          case '-':
            result = firstOperand.value - secondOperand;
            break;
          case '×':
            result = firstOperand.value * secondOperand;
            break;
          case '÷':
            result = firstOperand.value / secondOperand;
            break;
        }

        display.value = result.toString();
        if (display.value.endsWith('.0')) {
          display.value = display.value.substring(0, display.value.length - 2);
        } else if (display.value.contains('.')) {
          final decimalResult = double.parse(result.toStringAsFixed(2));
          display.value = decimalResult.toString();
          if (display.value.endsWith('.0')) {
            display.value =
                display.value.substring(0, display.value.length - 2);
          }
        }
        currentInput.value = display.value;
        firstOperand.value = result;
        operator.value = '';
        clearNext.value = true;
      }
    } else if (['+', '-', '×', '÷'].contains(value)) {
      if (currentInput.value.isNotEmpty) {
        if (operator.value.isNotEmpty && !clearNext.value) {
          final secondOperand = int.parse(currentInput.value);
          double result = 0;

          switch (operator.value) {
            case '+':
              result = firstOperand.value + secondOperand;
              break;
            case '-':
              result = firstOperand.value - secondOperand;
              break;
            case '×':
              result = firstOperand.value * secondOperand;
              break;
            case '÷':
              result = firstOperand.value / secondOperand;
              break;
          }

          display.value = result.toString();
          if (display.value.endsWith('.0')) {
            display.value =
                display.value.substring(0, display.value.length - 2);
          } else if (display.value.contains('.')) {
            final decimalResult = double.parse(result.toStringAsFixed(2));
            display.value = decimalResult.toString();
            if (display.value.endsWith('.0')) {
              display.value =
                  display.value.substring(0, display.value.length - 2);
            }
          }
          equation.value = '${equation.value} $secondOperand $value';
          currentInput.value = display.value;
          firstOperand.value = result;
        } else {
          firstOperand.value = double.parse(currentInput.value);
          if (clearNext.value) {
            equation.value = '${firstOperand.value} $value';
          } else {
            equation.value = '${currentInput.value} $value';
          }
        }
        operator.value = value;
        clearNext.value = true;
      } else if (firstOperand.value != 0) {
        operator.value = value;
        if (equation.value.isNotEmpty) {
          equation.value =
              equation.value.substring(0, equation.value.length - 1) + value;
        } else {
          equation.value = '${firstOperand.value} $value';
        }
      }
    } else {
      if (clearNext.value) {
        currentInput.value = '';
        clearNext.value = false;
      }

      if (currentInput.value == '0' && value != '.') {
        currentInput.value = value;
      } else {
        if (value == '.' && currentInput.value.contains('.')) {
          return;
        }
        currentInput.value += value;
      }
      display.value = currentInput.value;
    }
  }
}

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller instance when the widget is created
    final controller = Get.put(CalculatorController());

    final size = MediaQuery.of(context).size;
    final width = size.width * 0.85;
    final height = size.height * 0.7;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calculator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppConstantColors.defaultAccent.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            controller.equation.value,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          )),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            controller.display.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildButtonRow(controller, ['7', '8', '9', '÷']),
                        _buildButtonRow(controller, ['4', '5', '6', '×']),
                        _buildButtonRow(controller, ['1', '2', '3', '-']),
                        _buildButtonRow(controller, ['C', '0', '.', '+']),
                        _buildEqualAndBackspaceRow(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(
      CalculatorController controller, List<String> buttons) {
    return Expanded(
      child: Row(
        children:
            buttons.map((button) => _buildButton(controller, button)).toList(),
      ),
    );
  }

  Widget _buildButton(CalculatorController controller, String text) {
    final isOperator = ['+', '-', '×', '÷'].contains(text);
    final isSpecial = text == 'C';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => controller.updateDisplay(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: isOperator
                ? AppConstantColors.defaultAccent.withOpacity(0.8)
                : isSpecial
                    ? Colors.red.withOpacity(0.8)
                    : Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildEqualAndBackspaceRow(CalculatorController controller) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => controller.updateDisplay('='),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '=',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => controller.updateDisplay('⌫'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.backspace, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
