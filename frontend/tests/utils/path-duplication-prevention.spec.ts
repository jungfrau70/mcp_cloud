import { describe, it, expect } from 'vitest'
import { preventPathDuplication } from '~/utils/path'

describe('Path Duplication Prevention', () => {
  describe('preventPathDuplication', () => {
    it('should remove consecutive duplicate segments', () => {
      const input = 'cloud_basic/cloud_basic/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_basic/README.md')
    })

    it('should remove repeated course patterns', () => {
      const input = 'cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle complex duplication patterns', () => {
      const input = 'cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_basic/textbook/Day1/scripts/README.md')
    })

    it('should handle extreme duplication', () => {
      const input = 'cloud_container/textbook/Day2/'.repeat(10) + 'README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_container/textbook/Day2/README.md')
    })

    it('should handle mixed course patterns without removing different courses', () => {
      const input = 'cloud_basic/textbook/Day1/cloud_master/textbook/Day2/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_basic/textbook/Day1/cloud_master/textbook/Day2/README.md')
    })

    it('should handle empty string', () => {
      const result = preventPathDuplication('')
      expect(result).toBe('')
    })

    it('should handle null/undefined', () => {
      expect(preventPathDuplication(null as any)).toBe('')
      expect(preventPathDuplication(undefined as any)).toBe('')
    })

    it('should handle single segment', () => {
      const result = preventPathDuplication('README.md')
      expect(result).toBe('README.md')
    })

    it('should handle Windows path separators', () => {
      const input = 'cloud_master\\textbook\\Day1\\cloud_master\\textbook\\Day1\\README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle leading and trailing slashes', () => {
      const input = '/cloud_master/textbook/Day1/cloud_master/textbook/Day1/README.md/'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle multiple consecutive slashes', () => {
      const input = 'cloud_master///textbook///Day1///README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle textbook-only duplication', () => {
      const input = 'cloud_master/textbook/textbook/Day1/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle day-only duplication', () => {
      const input = 'cloud_master/textbook/Day1/Day1/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should handle complex nested duplication', () => {
      const input = 'cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/cloud_basic/textbook/Day1/scripts/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_basic/textbook/Day1/scripts/README.md')
    })

    it('should preserve valid complex paths', () => {
      const input = 'cloud_master/textbook/Day1/advanced/docker/kubernetes/README.md'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_master/textbook/Day1/advanced/docker/kubernetes/README.md')
    })

    it('should handle paths with different file extensions', () => {
      const input = 'cloud_basic/textbook/Day1/cloud_basic/textbook/Day1/script.sh'
      const result = preventPathDuplication(input)
      expect(result).toBe('cloud_basic/textbook/Day1/script.sh')
    })
  })
})
