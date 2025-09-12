import { describe, it, expect } from 'vitest'
import { 
  stripBasePath, 
  normalizePath, 
  cleanApiPath, 
  deepCleanApiPath,
  sanitizeGeneratedFilename 
} from '~/utils/path'

describe('Path Utils', () => {
  describe('stripBasePath', () => {
    it('should remove base path prefix', () => {
      expect(stripBasePath('mcp_knowledge_base/cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle paths without base path', () => {
      expect(stripBasePath('cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle Windows paths', () => {
      expect(stripBasePath('mcp_knowledge_base\\cloud_basic\\README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle leading slashes', () => {
      expect(stripBasePath('/mcp_knowledge_base/cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle empty string', () => {
      expect(stripBasePath('')).toBe('')
    })
  })

  describe('normalizePath', () => {
    it('should remove duplicate slashes', () => {
      expect(normalizePath('cloud_basic//README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle parent directory references', () => {
      expect(normalizePath('cloud_basic/../cloud_master/README.md'))
        .toBe('cloud_master/README.md')
    })

    it('should handle current directory references', () => {
      expect(normalizePath('cloud_basic/./README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle complex path normalization', () => {
      expect(normalizePath('cloud_basic/../cloud_master/./textbook/../README.md'))
        .toBe('cloud_master/README.md')
    })
  })

  describe('cleanApiPath', () => {
    it('should clean basic paths', () => {
      expect(cleanApiPath('mcp_knowledge_base/cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should remove consecutive duplicates', () => {
      expect(cleanApiPath('cloud_basic/cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle empty string', () => {
      expect(cleanApiPath('')).toBe('')
    })

    it('should handle null/undefined', () => {
      expect(cleanApiPath(null as any)).toBe('')
      expect(cleanApiPath(undefined as any)).toBe('')
    })
  })

  describe('deepCleanApiPath', () => {
    it('should remove repeated patterns', () => {
      const repeatedPath = 'cloud_master/textbook/Day3/cloud_master/textbook/Day3/cloud_master/textbook/Day3/README.md'
      expect(deepCleanApiPath(repeatedPath))
        .toBe('cloud_master/textbook/Day3/README.md')
    })

    it('should handle multiple course patterns', () => {
      const repeatedPath = 'cloud_basic/textbook/Day1/cloud_basic/textbook/Day1/README.md'
      expect(deepCleanApiPath(repeatedPath))
        .toBe('cloud_basic/textbook/Day1/README.md')
    })

    it('should handle container course patterns', () => {
      const repeatedPath = 'cloud_container/textbook/Day2/cloud_container/textbook/Day2/README.md'
      expect(deepCleanApiPath(repeatedPath))
        .toBe('cloud_container/textbook/Day2/README.md')
    })

    it('should clean complex duplicated paths', () => {
      const complexPath = 'cloud_master/textbook/Day3/cloud_master/textbook/Day3/cloud_master/textbook/Day3/cloud_master/textbook/Day3/README.md'
      expect(deepCleanApiPath(complexPath))
        .toBe('cloud_master/textbook/Day3/README.md')
    })

    it('should handle paths without repetition', () => {
      expect(deepCleanApiPath('cloud_basic/README.md'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle empty string', () => {
      expect(deepCleanApiPath('')).toBe('')
    })

    it('should handle null/undefined', () => {
      expect(deepCleanApiPath(null as any)).toBe('')
      expect(deepCleanApiPath(undefined as any)).toBe('')
    })

    it('should remove leading and trailing slashes', () => {
      expect(deepCleanApiPath('/cloud_basic/README.md/'))
        .toBe('cloud_basic/README.md')
    })

    it('should handle multiple consecutive slashes', () => {
      expect(deepCleanApiPath('cloud_basic///README.md'))
        .toBe('cloud_basic/README.md')
    })
  })

  describe('sanitizeGeneratedFilename', () => {
    it('should convert title to lowercase filename', () => {
      expect(sanitizeGeneratedFilename('Hello World'))
        .toBe('hello-world.md')
    })

    it('should remove special characters', () => {
      expect(sanitizeGeneratedFilename('Hello@#$%World!'))
        .toBe('helloworld.md')
    })

    it('should handle empty title', () => {
      const result = sanitizeGeneratedFilename('')
      expect(result).toMatch(/^generated-\d+\.md$/)
    })

    it('should handle title with only special characters', () => {
      const result = sanitizeGeneratedFilename('@#$%!')
      expect(result).toMatch(/^generated-\d+\.md$/)
    })

    it('should add .md extension if not present', () => {
      expect(sanitizeGeneratedFilename('hello world'))
        .toBe('hello-world.md')
    })

    it('should not add .md extension if already present', () => {
      expect(sanitizeGeneratedFilename('hello world'))
        .toBe('hello-world.md')
    })

    it('should handle Korean characters', () => {
      expect(sanitizeGeneratedFilename('안녕하세요'))
        .toBe('안녕하세요.md')
    })
  })
})
