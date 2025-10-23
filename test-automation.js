/**
 * 🧪 Automated Test Script สำหรับ iBit Repair System
 * ทดสอบระบบผ่าน API และ Frontend
 */

const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:4000';
const FRONTEND_URL = 'http://localhost:3000';

// Test Results
const testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

/**
 * Helper Functions
 */
function log(message, type = 'info') {
  const timestamp = new Date().toISOString();
  const prefix = type === 'error' ? '❌' : type === 'success' ? '✅' : 'ℹ️';
  console.log(`${prefix} [${timestamp}] ${message}`);
}

function recordTest(testName, status, details = '') {
  testResults.total++;
  if (status === 'PASS') {
    testResults.passed++;
  } else {
    testResults.failed++;
  }
  
  testResults.details.push({
    test: testName,
    status: status,
    details: details,
    timestamp: new Date().toISOString()
  });
  
  log(`${status}: ${testName} ${details ? `- ${details}` : ''}`, 
      status === 'PASS' ? 'success' : 'error');
}

/**
 * Test Functions
 */

// Test 1: Backend Health Check
async function testBackendHealth() {
  try {
    const response = await axios.get(`${API_BASE_URL}/health`);
    if (response.status === 200 && response.data.status === 'OK') {
      recordTest('Backend Health Check', 'PASS', 'Server is running');
      return true;
    } else {
      recordTest('Backend Health Check', 'FAIL', 'Invalid response');
      return false;
    }
  } catch (error) {
    recordTest('Backend Health Check', 'FAIL', error.message);
    return false;
  }
}

// Test 2: Admin Login
async function testAdminLogin() {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });
    
    if (response.status === 200 && response.data.token) {
      recordTest('Admin Login', 'PASS', 'Login successful');
      return response.data.token;
    } else {
      recordTest('Admin Login', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Admin Login', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 3: Technician Login
async function testTechnicianLogin() {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/auth/login`, {
      username: 'technician1',
      password: 'tech123'
    });
    
    if (response.status === 200 && response.data.token) {
      recordTest('Technician Login', 'PASS', 'Login successful');
      return response.data.token;
    } else {
      recordTest('Technician Login', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Technician Login', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 4: Invalid Login
async function testInvalidLogin() {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/auth/login`, {
      username: 'invaliduser',
      password: 'invalidpass'
    });
    
    // Should fail with 401
    recordTest('Invalid Login', 'FAIL', 'Expected 401 but got success');
    return false;
  } catch (error) {
    if (error.response?.status === 401) {
      recordTest('Invalid Login', 'PASS', 'Correctly rejected invalid credentials');
      return true;
    } else {
      recordTest('Invalid Login', 'FAIL', `Unexpected error: ${error.message}`);
      return false;
    }
  }
}

// Test 5: Create Brand
async function testCreateBrand(token) {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/brands`, {
      name: 'Test Brand',
      country: 'Thailand',
      website: 'https://testbrand.com'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 201 && response.data.name === 'Test Brand') {
      recordTest('Create Brand', 'PASS', 'Brand created successfully');
      return response.data.id;
    } else {
      recordTest('Create Brand', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Create Brand', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 6: Get All Brands
async function testGetBrands(token) {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/brands`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 200 && Array.isArray(response.data)) {
      recordTest('Get Brands', 'PASS', `Found ${response.data.length} brands`);
      return response.data;
    } else {
      recordTest('Get Brands', 'FAIL', 'Invalid response');
      return [];
    }
  } catch (error) {
    recordTest('Get Brands', 'FAIL', error.response?.data?.message || error.message);
    return [];
  }
}

// Test 7: Update Brand
async function testUpdateBrand(token, brandId) {
  try {
    const response = await axios.put(`${API_BASE_URL}/api/brands/${brandId}`, {
      name: 'Updated Test Brand',
      country: 'Thailand',
      website: 'https://updatedtestbrand.com'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 200 && response.data.name === 'Updated Test Brand') {
      recordTest('Update Brand', 'PASS', 'Brand updated successfully');
      return true;
    } else {
      recordTest('Update Brand', 'FAIL', 'Invalid response');
      return false;
    }
  } catch (error) {
    recordTest('Update Brand', 'FAIL', error.response?.data?.message || error.message);
    return false;
  }
}

// Test 8: Delete Brand
async function testDeleteBrand(token, brandId) {
  try {
    const response = await axios.delete(`${API_BASE_URL}/api/brands/${brandId}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 200) {
      recordTest('Delete Brand', 'PASS', 'Brand deleted successfully');
      return true;
    } else {
      recordTest('Delete Brand', 'FAIL', 'Invalid response');
      return false;
    }
  } catch (error) {
    recordTest('Delete Brand', 'FAIL', error.response?.data?.message || error.message);
    return false;
  }
}

// Test 9: Create Model
async function testCreateModel(token, brandId) {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/models`, {
      name: 'Test Miner S19',
      brandId: brandId,
      hashrate: '95 TH/s',
      powerUsage: '3250W',
      releaseDate: '2023-01-01',
      description: 'Test mining model'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 201 && response.data.name === 'Test Miner S19') {
      recordTest('Create Model', 'PASS', 'Model created successfully');
      return response.data.id;
    } else {
      recordTest('Create Model', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Create Model', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 10: Create Warranty Profile
async function testCreateWarranty(token) {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/warranties`, {
      name: 'Standard Warranty',
      partsWarranty: 12,
      laborWarranty: 6,
      conditions: 'รับประกันเฉพาะอะไหล่ที่เปลี่ยน'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 201 && response.data.name === 'Standard Warranty') {
      recordTest('Create Warranty', 'PASS', 'Warranty created successfully');
      return response.data.id;
    } else {
      recordTest('Create Warranty', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Create Warranty', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 11: Create Part
async function testCreatePart(token) {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/parts`, {
      name: 'Test ASIC Chip',
      partNumber: 'TEST-CHIP-001',
      unitPrice: 5000,
      stockQuantity: 10,
      minStockQty: 5,
      location: 'A1-B2',
      description: 'Test ASIC chip for mining'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 201 && response.data.name === 'Test ASIC Chip') {
      recordTest('Create Part', 'PASS', 'Part created successfully');
      return response.data.id;
    } else {
      recordTest('Create Part', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Create Part', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 12: Update Part Stock
async function testUpdatePartStock(token, partId) {
  try {
    const response = await axios.put(`${API_BASE_URL}/api/parts/${partId}/stock`, {
      stockQuantity: 15
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 200 && response.data.stockQuantity === 15) {
      recordTest('Update Part Stock', 'PASS', 'Stock updated successfully');
      return true;
    } else {
      recordTest('Update Part Stock', 'FAIL', 'Invalid response');
      return false;
    }
  } catch (error) {
    recordTest('Update Part Stock', 'FAIL', error.response?.data?.message || error.message);
    return false;
  }
}

// Test 13: Create Customer
async function testCreateCustomer(token) {
  try {
    const response = await axios.post(`${API_BASE_URL}/api/customers`, {
      name: 'ทดสอบ ลูกค้า',
      phone: '081-234-5678',
      email: 'test@customer.com',
      address: '123 ถนนทดสอบ กรุงเทพฯ'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 201 && response.data.fullName === 'ทดสอบ ลูกค้า') {
      recordTest('Create Customer', 'PASS', 'Customer created successfully');
      return response.data.id;
    } else {
      recordTest('Create Customer', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Create Customer', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

// Test 14: Get Current User
async function testGetCurrentUser(token) {
  try {
    const response = await axios.get(`${API_BASE_URL}/api/auth/me`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (response.status === 200 && response.data.username) {
      recordTest('Get Current User', 'PASS', `User: ${response.data.username}`);
      return response.data;
    } else {
      recordTest('Get Current User', 'FAIL', 'Invalid response');
      return null;
    }
  } catch (error) {
    recordTest('Get Current User', 'FAIL', error.response?.data?.message || error.message);
    return null;
  }
}

/**
 * Main Test Execution
 */
async function runAllTests() {
  log('🚀 Starting iBit Repair System Test Suite');
  log('=' .repeat(50));
  
  // Test 1: Backend Health
  const backendHealthy = await testBackendHealth();
  if (!backendHealthy) {
    log('❌ Backend is not healthy. Stopping tests.');
    return;
  }
  
  // Test 2: Authentication Tests
  const adminToken = await testAdminLogin();
  const technicianToken = await testTechnicianLogin();
  await testInvalidLogin();
  
  if (!adminToken) {
    log('❌ Admin login failed. Stopping tests.');
    return;
  }
  
  // Test 3: Get Current User
  await testGetCurrentUser(adminToken);
  
  // Test 4: Brands CRUD
  const brandId = await testCreateBrand(adminToken);
  await testGetBrands(adminToken);
  if (brandId) {
    await testUpdateBrand(adminToken, brandId);
    await testDeleteBrand(adminToken, brandId);
  }
  
  // Test 5: Create a brand for model testing
  const testBrandId = await testCreateBrand(adminToken);
  
  // Test 6: Models CRUD
  if (testBrandId) {
    await testCreateModel(adminToken, testBrandId);
  }
  
  // Test 7: Warranty Profiles
  await testCreateWarranty(adminToken);
  
  // Test 8: Parts CRUD
  const partId = await testCreatePart(adminToken);
  if (partId) {
    await testUpdatePartStock(adminToken, partId);
  }
  
  // Test 9: Customers CRUD
  await testCreateCustomer(adminToken);
  
  // Test Summary
  log('=' .repeat(50));
  log('📊 Test Results Summary');
  log(`✅ Passed: ${testResults.passed}`);
  log(`❌ Failed: ${testResults.failed}`);
  log(`📈 Total: ${testResults.total}`);
  log(`📊 Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);
  
  // Detailed Results
  log('=' .repeat(50));
  log('📋 Detailed Results:');
  testResults.details.forEach((result, index) => {
    const icon = result.status === 'PASS' ? '✅' : '❌';
    log(`${index + 1}. ${icon} ${result.test} - ${result.details}`);
  });
  
  // Exit with appropriate code
  process.exit(testResults.failed > 0 ? 1 : 0);
}

// Error handling
process.on('unhandledRejection', (reason, promise) => {
  log(`Unhandled Rejection at: ${promise}, reason: ${reason}`, 'error');
  process.exit(1);
});

// Run tests
runAllTests().catch((error) => {
  log(`Test execution failed: ${error.message}`, 'error');
  process.exit(1);
});

module.exports = {
  runAllTests,
  testResults
};
