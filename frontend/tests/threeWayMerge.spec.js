import { describe, it, expect } from 'vitest'
import { merge3 } from '../utils/threeWayMerge'

describe('merge3', () => {
  it('returns identical when local==upstream', () => {
    const base = 'a\nb\nc'
    const local = 'a\nb\nc'
    const up = 'a\nb\nc'
    const { merged, conflicts } = merge3(base, local, up)
    expect(merged).toBe(local)
    expect(conflicts).toBe(0)
  })

  it('prefers changed when only one side differs', () => {
    const base = 'a\nb\nc'
    const local = 'a\nB\nc'
    const up = 'a\nb\nc'
    const { merged, conflicts } = merge3(base, local, up)
    expect(merged.includes('B')).toBe(true)
    expect(conflicts).toBe(0)
  })

  it('creates conflict when both sides diverge differently', () => {
    const base = 'line'
    const local = 'line-local'
    const up = 'line-up'
    const { merged, conflicts } = merge3(base, local, up)
    expect(conflicts).toBe(1)
    expect(merged).toMatch(/<<<<<<< LOCAL/)    
  })
})
