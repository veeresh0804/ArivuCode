import '../core/models/challenge_model.dart';
import '../core/constants/app_constants.dart';

/// Mock challenge repository with sample challenges
class ChallengeRepository {
  ChallengeRepository._();

  static final List<Challenge> _mockChallenges = [
    Challenge(
      id: 'ch001',
      title: 'Two Sum',
      description: '''Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

**Example:**
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].''',
      difficulty: AppConstants.difficultyEasy,
      points: AppConstants.pointsEasy,
      timeLimit: AppConstants.timeLimitEasy,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(
          input: '[2,7,11,15]\n9',
          expectedOutput: '[0,1]',
        ),
        const TestCase(
          input: '[3,2,4]\n6',
          expectedOutput: '[1,2]',
        ),
        const TestCase(
          input: '[3,3]\n6',
          expectedOutput: '[0,1]',
        ),
      ],
      starterCode: {
        'Python': '''def two_sum(nums, target):
    # Write your code here
    pass

# Test
nums = list(map(int, input().split(',')))
target = int(input())
result = two_sum(nums, target)
print(result)''',
        'Java': '''import java.util.*;

public class Solution {
    public int[] twoSum(int[] nums, int target) {
        // Write your code here
        return new int[]{};
    }
    
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        // Implementation
    }
}''',
        'C++': '''#include <iostream>
#include <vector>
using namespace std;

vector<int> twoSum(vector<int>& nums, int target) {
    // Write your code here
    return {};
}

int main() {
    // Implementation
    return 0;
}''',
      },
      tags: ['array', 'hash-table', 'easy'],
      hints: 'Try using a hash map to store the complement of each number.',
      solvedCount: 1234,
      successRate: 85.5,
      createdAt: DateTime(2024, 1, 1),
    ),
    
    Challenge(
      id: 'ch002',
      title: 'Reverse String',
      description: '''Write a function that reverses a string. The input string is given as an array of characters.

You must do this by modifying the input array in-place with O(1) extra memory.

**Example:**
Input: s = ["h","e","l","l","o"]
Output: ["o","l","l","e","h"]''',
      difficulty: AppConstants.difficultyEasy,
      points: AppConstants.pointsEasy,
      timeLimit: AppConstants.timeLimitEasy,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(
          input: 'hello',
          expectedOutput: 'olleh',
        ),
        const TestCase(
          input: 'ArivuCode',
          expectedOutput: 'edoCuvirA',
        ),
      ],
      starterCode: {
        'Python': '''def reverse_string(s):
    # Write your code here
    pass

# Test
s = input()
result = reverse_string(s)
print(result)''',
        'C': '''#include <stdio.h>
#include <string.h>

void reverseString(char* s) {
    // Write your code here
}

int main() {
    char s[100];
    scanf("%s", s);
    reverseString(s);
    printf("%s", s);
    return 0;
}''',
      },
      tags: ['string', 'two-pointers'],
      solvedCount: 2456,
      successRate: 92.3,
      createdAt: DateTime(2024, 1, 2),
    ),
    
    Challenge(
      id: 'ch003',
      title: 'Palindrome Number',
      description: '''Given an integer x, return true if x is a palindrome, and false otherwise.

An integer is a palindrome when it reads the same backward as forward.

**Example:**
Input: x = 121
Output: true
Explanation: 121 reads as 121 from left to right and from right to left.''',
      difficulty: AppConstants.difficultyEasy,
      points: AppConstants.pointsEasy,
      timeLimit: AppConstants.timeLimitEasy,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(input: '121', expectedOutput: 'true'),
        const TestCase(input: '-121', expectedOutput: 'false'),
        const TestCase(input: '10', expectedOutput: 'false'),
      ],
      starterCode: {
        'Python': '''def is_palindrome(x):
    # Write your code here
    pass

# Test
x = int(input())
result = is_palindrome(x)
print(str(result).lower())''',
      },
      tags: ['math', 'palindrome'],
      solvedCount: 1876,
      successRate: 88.7,
      createdAt: DateTime(2024, 1, 3),
    ),
    
    Challenge(
      id: 'ch004',
      title: 'Valid Parentheses',
      description: '''Given a string s containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.

An input string is valid if:
1. Open brackets must be closed by the same type of brackets.
2. Open brackets must be closed in the correct order.

**Example:**
Input: s = "()[]{}"
Output: true''',
      difficulty: AppConstants.difficultyMedium,
      points: AppConstants.pointsMedium,
      timeLimit: AppConstants.timeLimitMedium,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(input: '()[]{}', expectedOutput: 'true'),
        const TestCase(input: '(]', expectedOutput: 'false'),
        const TestCase(input: '([)]', expectedOutput: 'false'),
      ],
      starterCode: {
        'Python': '''def is_valid(s):
    # Write your code here
    pass

# Test
s = input()
result = is_valid(s)
print(str(result).lower())''',
      },
      tags: ['stack', 'string'],
      hints: 'Use a stack data structure to keep track of opening brackets.',
      solvedCount: 987,
      successRate: 72.4,
      createdAt: DateTime(2024, 1, 4),
    ),
    
    Challenge(
      id: 'ch005',
      title: 'Fibonacci Number',
      description: '''The Fibonacci numbers, commonly denoted F(n) form a sequence, called the Fibonacci sequence, such that each number is the sum of the two preceding ones, starting from 0 and 1.

Given n, calculate F(n).

**Example:**
Input: n = 4
Output: 3
Explanation: F(4) = F(3) + F(2) = 2 + 1 = 3.''',
      difficulty: AppConstants.difficultyMedium,
      points: AppConstants.pointsMedium,
      timeLimit: AppConstants.timeLimitMedium,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(input: '2', expectedOutput: '1'),
        const TestCase(input: '3', expectedOutput: '2'),
        const TestCase(input: '4', expectedOutput: '3'),
        const TestCase(input: '10', expectedOutput: '55'),
      ],
      starterCode: {
        'Python': '''def fibonacci(n):
    # Write your code here
    pass

# Test
n = int(input())
result = fibonacci(n)
print(result)''',
      },
      tags: ['recursion', 'dynamic-programming', 'math'],
      hints: 'Try using dynamic programming or memoization for efficiency.',
      solvedCount: 1543,
      successRate: 79.2,
      createdAt: DateTime(2024, 1, 5),
    ),
    
    Challenge(
      id: 'ch006',
      title: 'Merge Sorted Arrays',
      description: '''You are given two integer arrays nums1 and nums2, sorted in non-decreasing order. Merge nums2 into nums1 as one sorted array.

**Example:**
Input: nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3
Output: [1,2,2,3,5,6]''',
      difficulty: AppConstants.difficultyHard,
      points: AppConstants.pointsHard,
      timeLimit: AppConstants.timeLimitHard,
      supportedLanguages: AppConstants.supportedLanguages,
      testCases: [
        const TestCase(
          input: '[1,2,3,0,0,0]\n3\n[2,5,6]\n3',
          expectedOutput: '[1,2,2,3,5,6]',
        ),
      ],
      starterCode: {
        'Python': '''def merge(nums1, m, nums2, n):
    # Write your code here
    pass

# Test
nums1 = list(map(int, input().split(',')))
m = int(input())
nums2 = list(map(int, input().split(',')))
n = int(input())
merge(nums1, m, nums2, n)
print(nums1)''',
      },
      tags: ['array', 'two-pointers', 'sorting'],
      hints: 'Start from the end of both arrays and work backwards.',
      solvedCount: 456,
      successRate: 58.9,
      createdAt: DateTime(2024, 1, 6),
    ),
  ];

  /// Get all challenges
  static Future<List<Challenge>> getAllChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return List.from(_mockChallenges);
  }

  /// Get challenge by ID
  static Future<Challenge?> getChallengeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockChallenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get challenges by difficulty
  static Future<List<Challenge>> getChallengesByDifficulty(String difficulty) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockChallenges.where((c) => c.difficulty == difficulty).toList();
  }

  /// Get challenges by tag
  static Future<List<Challenge>> getChallengesByTag(String tag) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockChallenges.where((c) => c.tags.contains(tag)).toList();
  }

  /// Search challenges
  static Future<List<Challenge>> searchChallenges(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return _mockChallenges.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
