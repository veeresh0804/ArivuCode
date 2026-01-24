import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Language-specific code templates
class CodeTemplates {
  CodeTemplates._();

  static const Map<String, String> templates = {
    'Python': '''# Python Code
def main():
    print("Hello, ArivuCode!")

if __name__ == "__main__":
    main()
''',
    'C': '''// C Code
#include <stdio.h>

int main() {
    printf("Hello, ArivuCode!\\n");
    return 0;
}
''',
    'C++': '''// C++ Code
#include <iostream>
using namespace std;

int main() {
    cout << "Hello, ArivuCode!" << endl;
    return 0;
}
''',
    'Java': '''// Java Code
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, ArivuCode!");
    }
}
''',
    'JavaScript': '''// JavaScript Code
function main() {
    console.log("Hello, ArivuCode!");
}

main();
''',
    'Rust': '''// Rust Code
fn main() {
    println!("Hello, ArivuCode!");
}
''',
    'Go': '''// Go Code
package main
import "fmt"

func main() {
    fmt.Println("Hello, ArivuCode!")
}
''',
    'TypeScript': '''// TypeScript Code
function main(): void {
    console.log("Hello, ArivuCode!");
}

main();
''',
    'Kotlin': '''// Kotlin Code
fun main() {
    println("Hello, ArivuCode!")
}
''',
  };

  /// Get template for a specific language
  static String getTemplate(String language) {
    return templates[language] ?? '';
  }

  /// Get empty template (just a comment)
  static String getEmptyTemplate(String language) {
    return switch (language) {
      'Python' => '# Write your Python code here\n',
      'C' || 'C++' || 'Java' || 'JavaScript' || 'TypeScript' || 'Rust' || 'Go' || 'Kotlin' => '// Write your $language code here\n',
      _ => '// Write your code here\n',
    };
  }

  /// Get file extension for language
  static String getExtension(String language) {
    return AppConstants.languageExtensions[language] ?? '.txt';
  }

  /// Get language icon
  static String getIcon(String language) {
    return AppConstants.languageIcons[language] ?? '📝';
  }
}
