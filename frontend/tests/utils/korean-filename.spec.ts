import { describe, it, expect } from 'vitest'
import { 
  isReadableFilename, 
  isEncodedFilename, 
  needsDecoding, 
  analyzeFilename,
  encodeKoreanPath,
  decodeKoreanPath,
  prepareApiPath,
  processPathSafely,
  safeEncodeURIComponent,
  safeDecodeURIComponent,
  validatePath,
  getPathErrorLog,
  clearPathErrorLog,
  robustSafeEncodeURIComponent
} from '~/utils/path'

describe('Korean Filename Handling', () => {
  describe('isReadableFilename', () => {
    it('should return true for ASCII-only filenames', () => {
      expect(isReadableFilename('README.md')).toBe(true)
      expect(isReadableFilename('index.html')).toBe(true)
      expect(isReadableFilename('test-file.txt')).toBe(true)
    })

    it('should return true for Korean filenames without encoding', () => {
      expect(isReadableFilename('과정명.md')).toBe(true)
      expect(isReadableFilename('과정상세.md')).toBe(true)
      expect(isReadableFilename('클라우드기초.md')).toBe(true)
    })

    it('should return false for encoded filenames', () => {
      expect(isReadableFilename('%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe(false)
      expect(isReadableFilename('%25EA%25B3%25BC%25EC%25A0%2595%25EB%25AA%2585.md')).toBe(false)
    })
  })

  describe('isEncodedFilename', () => {
    it('should return true for URL-encoded filenames', () => {
      expect(isEncodedFilename('%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe(true)
      expect(isEncodedFilename('%25EA%25B3%25BC%25EC%25A0%2595%25EB%25AA%2585.md')).toBe(true)
    })

    it('should return false for non-encoded filenames', () => {
      expect(isEncodedFilename('README.md')).toBe(false)
      expect(isEncodedFilename('과정명.md')).toBe(false)
    })
  })

  describe('needsDecoding', () => {
    it('should return true for encoded filenames that need decoding', () => {
      expect(needsDecoding('%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe(true)
      expect(needsDecoding('%25EA%25B3%25BC%25EC%25A0%2595%25EB%25AA%2585.md')).toBe(true)
    })

    it('should return false for non-encoded filenames', () => {
      expect(needsDecoding('README.md')).toBe(false)
      expect(needsDecoding('과정명.md')).toBe(false)
    })
  })

  describe('analyzeFilename', () => {
    it('should analyze ASCII filenames correctly', () => {
      const result = analyzeFilename('README.md')
      expect(result.isReadable).toBe(true)
      expect(result.isEncoded).toBe(false)
      expect(result.needsDecoding).toBe(false)
      expect(result.encodingLevel).toBe(0)
    })

    it('should analyze Korean filenames correctly', () => {
      const result = analyzeFilename('과정명.md')
      expect(result.isReadable).toBe(true)
      expect(result.isEncoded).toBe(false)
      expect(result.needsDecoding).toBe(false)
      expect(result.encodingLevel).toBe(0)
    })

    it('should analyze single-encoded filenames correctly', () => {
      const result = analyzeFilename('%EA%B3%BC%EC%A0%95%EB%AA%85.md')
      expect(result.isReadable).toBe(false)
      expect(result.isEncoded).toBe(true)
      expect(result.needsDecoding).toBe(true)
      expect(result.encodingLevel).toBe(1)
      expect(result.decoded).toBe('과정명.md')
    })

    it('should analyze double-encoded filenames correctly', () => {
      const result = analyzeFilename('%25EA%25B3%25BC%25EC%25A0%2595%25EB%25AA%2585.md')
      expect(result.isReadable).toBe(false)
      expect(result.isEncoded).toBe(true)
      expect(result.needsDecoding).toBe(true)
      expect(result.encodingLevel).toBe(2)
      expect(result.decoded).toBe('과정명.md')
    })
  })

  describe('encodeKoreanPath', () => {
    it('should encode Korean characters in path segments', () => {
      expect(encodeKoreanPath('cloud_basic/과정명.md')).toBe('cloud_basic/%EA%B3%BC%EC%A0%95%EB%AA%85.md')
      expect(encodeKoreanPath('cloud_basic/과정상세.md')).toBe('cloud_basic/%EA%B3%BC%EC%A0%95%EC%83%81%EC%84%B8.md')
    })

    it('should not encode ASCII-only segments', () => {
      expect(encodeKoreanPath('cloud_basic/README.md')).toBe('cloud_basic/README.md')
      expect(encodeKoreanPath('textbook/Day1/index.md')).toBe('textbook/Day1/index.md')
    })
  })

  describe('decodeKoreanPath', () => {
    it('should decode Korean characters correctly', () => {
      expect(decodeKoreanPath('%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe('과정명.md')
      expect(decodeKoreanPath('cloud_basic/%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe('cloud_basic/과정명.md')
    })

    it('should handle non-encoded paths', () => {
      expect(decodeKoreanPath('README.md')).toBe('README.md')
      expect(decodeKoreanPath('cloud_basic/README.md')).toBe('cloud_basic/README.md')
    })

    it('should handle invalid encoding gracefully', () => {
      expect(decodeKoreanPath('%invalid')).toBe('%invalid')
    })
  })

  describe('prepareApiPath', () => {
    it('should prepare Korean paths for API calls', () => {
      expect(prepareApiPath('cloud_basic/과정명.md')).toBe('cloud_basic/%EA%B3%BC%EC%A0%95%EB%AA%85.md')
      expect(prepareApiPath('cloud_basic/과정상세.md')).toBe('cloud_basic/%EA%B3%BC%EC%A0%95%EC%83%81%EC%84%B8.md')
    })

    it('should handle already encoded paths', () => {
      expect(prepareApiPath('cloud_basic/%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe('cloud_basic/%EA%B3%BC%EC%A0%95%EB%AA%85.md')
    })

    it('should handle ASCII-only paths', () => {
      expect(prepareApiPath('cloud_basic/README.md')).toBe('cloud_basic/README.md')
    })
  })

  // ===== 개선된 함수들 테스트 =====
  
  describe('safeEncodeURIComponent', () => {
    it('should encode Korean characters safely', () => {
      expect(safeEncodeURIComponent('과정명.md')).toBe('%EA%B3%BC%EC%A0%95%EB%AA%85.md')
      expect(safeEncodeURIComponent('과정상세.md')).toBe('%EA%B3%BC%EC%A0%95%EC%83%81%EC%84%B8.md')
    })

    it('should prevent double encoding', () => {
      const encoded = encodeURIComponent('과정명.md')
      expect(safeEncodeURIComponent(encoded)).toBe(encoded)
    })

    it('should handle empty strings', () => {
      expect(safeEncodeURIComponent('')).toBe('')
    })
  })

  describe('safeDecodeURIComponent', () => {
    it('should decode Korean characters safely', () => {
      expect(safeDecodeURIComponent('%EA%B3%BC%EC%A0%95%EB%AA%85.md')).toBe('과정명.md')
      expect(safeDecodeURIComponent('%EA%B3%BC%EC%A0%95%EC%83%81%EC%84%B8.md')).toBe('과정상세.md')
    })

    it('should handle double encoding', () => {
      const doubleEncoded = encodeURIComponent(encodeURIComponent('과정명.md'))
      expect(safeDecodeURIComponent(doubleEncoded)).toBe('과정명.md')
    })

    it('should handle non-encoded strings', () => {
      expect(safeDecodeURIComponent('README.md')).toBe('README.md')
    })
  })

  describe('validatePath', () => {
    it('should validate correct paths', () => {
      const result = validatePath('cloud_basic/과정명.md')
      expect(result.isValid).toBe(true)
      expect(result.errors).toHaveLength(0)
    })

    it('should reject empty paths', () => {
      const result = validatePath('')
      expect(result.isValid).toBe(false)
      expect(result.errors).toContain('Path is empty')
    })

    it('should reject paths with invalid characters', () => {
      const result = validatePath('cloud_basic/test<file.md')
      expect(result.isValid).toBe(false)
      expect(result.errors).toContain('Path contains invalid characters')
    })

    it('should reject dangerous relative paths', () => {
      const result = validatePath('../../../etc/passwd')
      expect(result.isValid).toBe(false)
      expect(result.errors).toContain('Path contains potentially dangerous relative path')
    })
  })

  describe('processPathSafely', () => {
    it('should process Korean paths safely', () => {
      const result = processPathSafely('과정명.md', 'encode')
      expect(result.success).toBe(true)
      expect(result.result).toBe('%EA%B3%BC%EC%A0%95%EB%AA%85.md')
      expect(result.errors).toHaveLength(0)
    })

    it('should decode encoded paths safely', () => {
      const result = processPathSafely('%EA%B3%BC%EC%A0%95%EB%AA%85.md', 'decode')
      expect(result.success).toBe(true)
      expect(result.result).toBe('과정명.md')
      expect(result.errors).toHaveLength(0)
    })

    it('should handle auto mode correctly', () => {
      const encodedResult = processPathSafely('과정명.md', 'auto')
      expect(encodedResult.success).toBe(true)
      expect(encodedResult.result).toBe('%EA%B3%BC%EC%A0%95%EB%AA%85.md')

      const decodedResult = processPathSafely('%EA%B3%BC%EC%A0%95%EB%AA%85.md', 'auto')
      expect(decodedResult.success).toBe(true)
      expect(decodedResult.result).toBe('과정명.md')
    })

    it('should handle invalid inputs gracefully', () => {
      const result = processPathSafely('', 'encode')
      expect(result.success).toBe(false)
      expect(result.errors).toContain('Path is empty')
    })
  })

  describe('Error Logging', () => {
    it('should log errors when processing fails', () => {
      // Clear previous errors first
      clearPathErrorLog()
      
      // Process an invalid path to generate an error using robustSafeEncodeURIComponent directly
      // This should trigger validation error
      robustSafeEncodeURIComponent(123 as any) // This should trigger validation error
      
      const errors = getPathErrorLog()
      expect(errors.length).toBeGreaterThan(0)
      
      // Check error structure
      if (errors.length > 0) {
        const error = errors[errors.length - 1]
        expect(error).toHaveProperty('type')
        expect(error).toHaveProperty('message')
        expect(error).toHaveProperty('originalValue')
        expect(error).toHaveProperty('timestamp')
      }
    })
  })
})
