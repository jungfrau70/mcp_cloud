import { describe, it, expect } from 'vitest'
import { 
  processKnowledgeBasePath,
  // cleanApiPath,
  // prepareApiPath,
  processPathSafely
} from '~/utils/path'

describe('Path Processing Consistency', () => {
  describe('processKnowledgeBasePath', () => {
    it('should handle Windows path issues consistently', () => {
      const testCases = [
        {
          input: 'cloud_master\\textbook\\Day1\\masterepos\\script.sh',
          expected: 'cloud_master/textbook/Day1/master/repos/script.sh'
        },
        {
          input: 'cloud_container\\textbook\\Day2\\containerepos\\docker-compose.yml',
          expected: 'cloud_container/textbook/Day2/container/repos/docker-compose.yml'
        },
        {
          input: 'cloud_basic\\textbook\\Day1\\basicrepos\\setup.sh',
          expected: 'cloud_basic/textbook/Day1/basic/repos/setup.sh'
        }
      ]

      for (const testCase of testCases) {
        const result = processKnowledgeBasePath(testCase.input, {
          addPrefix: false,
          encode: false,
          fixWindowsPaths: true
        })
        
        expect(result.success).toBe(true)
        expect(result.result).toBe(testCase.expected)
      }
    })

    it('should add mcp_knowledge_base prefix consistently', () => {
      const testCases = [
        {
          input: 'cloud_master/README.md',
          expected: 'mcp_knowledge_base/cloud_master/README.md'
        },
        {
          input: 'mcp_knowledge_base/cloud_master/README.md',
          expected: 'mcp_knowledge_base/cloud_master/README.md' // 중복 추가 방지
        }
      ]

      for (const testCase of testCases) {
        const result = processKnowledgeBasePath(testCase.input, {
          addPrefix: true,
          encode: false,
          fixWindowsPaths: false
        })
        
        expect(result.success).toBe(true)
        expect(result.result).toBe(testCase.expected)
      }
    })

    it('should handle Korean filenames consistently', () => {
      const testCases = [
        {
          input: 'cloud_master/과정명.md',
          expected: 'mcp_knowledge_base/cloud_master/%EA%B3%BC%EC%A0%95%EB%AA%85.md'
        },
        {
          input: 'cloud_master/%EA%B3%BC%EC%A0%95%EB%AA%85.md',
          expected: 'mcp_knowledge_base/cloud_master/%EA%B3%BC%EC%A0%95%EB%AA%85.md'
        }
      ]

      for (const testCase of testCases) {
        const result = processKnowledgeBasePath(testCase.input, {
          addPrefix: true,
          encode: true,
          fixWindowsPaths: false
        })
        
        expect(result.success).toBe(true)
        expect(result.result).toBe(testCase.expected)
      }
    })

    it('should handle complex path scenarios consistently', () => {
      const complexPath = 'cloud_master\\textbook\\Day3\\masterepos\\과정명.md'
      const result = processKnowledgeBasePath(complexPath, {
        addPrefix: true,
        encode: true,
        fixWindowsPaths: true
      })
      
      expect(result.success).toBe(true)
      expect(result.result).toBe('mcp_knowledge_base/cloud_master/textbook/Day3/master/repos/%EA%B3%BC%EC%A0%95%EB%AA%85.md')
    })
  })

  describe('Legacy function compatibility', () => {
    it('should maintain compatibility with cleanApiPath functionality', () => {
      const testPath = 'mcp_knowledge_base/cloud_master/textbook/Day1/README.md'
      const result = processKnowledgeBasePath(testPath, { 
        addPrefix: false, 
        encode: false, 
        fixWindowsPaths: false,
        stripBasePath: true,
        normalize: true
      })
      expect(result.success).toBe(true)
      expect(result.result).toBe('cloud_master/textbook/Day1/README.md')
    })

    it('should maintain compatibility with prepareApiPath functionality', () => {
      const testPath = 'cloud_master/과정명.md'
      const result = processKnowledgeBasePath(testPath, { 
        addPrefix: true, 
        encode: true, 
        fixWindowsPaths: true,
        stripBasePath: false,
        normalize: true
      })
      expect(result.success).toBe(true)
      expect(result.result).toBe('mcp_knowledge_base/cloud_master/%EA%B3%BC%EC%A0%95%EB%AA%85.md')
    })

    it('should maintain compatibility with processPathSafely', () => {
      const testPath = '과정명.md'
      const result = processPathSafely(testPath, 'encode')
      expect(result.success).toBe(true)
      expect(result.result).toBe('%EA%B3%BC%EC%A0%95%EB%AA%85.md')
    })
  })

  describe('Error handling consistency', () => {
    it('should handle empty paths consistently', () => {
      const result = processKnowledgeBasePath('', {
        addPrefix: true,
        encode: true,
        fixWindowsPaths: true
      })
      
      expect(result.success).toBe(true)
      expect(result.result).toBe('mcp_knowledge_base/')
    })

    it('should handle null/undefined paths consistently', () => {
      const result1 = processKnowledgeBasePath(null as any, {
        addPrefix: true,
        encode: true,
        fixWindowsPaths: true
      })
      
      const result2 = processKnowledgeBasePath(undefined as any, {
        addPrefix: true,
        encode: true,
        fixWindowsPaths: true
      })
      
      expect(result1.success).toBe(true)
      expect(result1.result).toBe('mcp_knowledge_base/')
      expect(result2.success).toBe(true)
      expect(result2.result).toBe('mcp_knowledge_base/')
    })
  })
})
