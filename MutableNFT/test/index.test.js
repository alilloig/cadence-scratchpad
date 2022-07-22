import path from "path";
import * as types from "@onflow/types";
import {
  init,
  sendTransaction,
  deployContractByName,
  getTransactionCode,
} from "flow-js-testing/dist";
import { getScriptCode } from "flow-js-testing/dist/utils/file";
import { executeScript } from "flow-js-testing/dist/utils/interaction";
import { getContractAddress } from "flow-js-testing/dist/utils/contract";
import { getAccountAddress } from "flow-js-testing/dist/utils/create-account";

const basePath = path.resolve(__dirname, "../MutableNFT");

beforeAll(() => {
  init(basePath);
});

describe("Replicate Playground Accounts", () => {
  test("Create Accounts", async () => {
    // Playground project support 4 accounts, but nothing stops you from creating more by following the example laid out below
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    const Dave = await getAccountAddress("Dave");

    console.log(
      "Four Playground accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
  });
});

describe("Deployment", () => {
  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("Alice");

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("Bob");

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");

    const addressMap = {
      NonFungibleToken,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("Charlie");

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const RemoteControl = await getContractAddress("RemoteControl");

    const addressMap = {
      NonFungibleToken,
      RemoteControl,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("");

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const RemoteControl = await getContractAddress("RemoteControl");

    const addressMap = {
      NonFungibleToken,
      RemoteControl,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });
});

describe("Transactions", () => {
  test("test transaction template Setup ExampleNFT Collection", async () => {
    const name = "Setup ExampleNFT Collection";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const RemoteControl = await getContractAddress("RemoteControl");
    const ExampleNFT = await getContractAddress("ExampleNFT");

    const addressMap = {
      NonFungibleToken,
      RemoteControl,
      ExampleNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template Mint NFT", async () => {
    const name = "Mint NFT";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [["0x0ae53cb6e3f42a79", types.Address]];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const ExampleNFT = await getContractAddress("ExampleNFT");

    const addressMap = {
      NonFungibleToken,
      ExampleNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template Mutate NFT", async () => {
    const name = "Mutate NFT";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
    ];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const RemoteControl = await getContractAddress("RemoteControl");
    const ExampleNFT = await getContractAddress("ExampleNFT");

    const addressMap = {
      NonFungibleToken,
      RemoteControl,
      ExampleNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });
});

describe("Scripts", () => {
  test("test script template Get NFT state", async () => {
    const name = "Get NFT state";

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const ExampleNFT = await getContractAddress("ExampleNFT");

    const addressMap = {
      NonFungibleToken,
      ExampleNFT,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
    ];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template Get Account NFTs", async () => {
    const name = "Get Account NFTs";

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const ExampleNFT = await getContractAddress("ExampleNFT");

    const addressMap = {
      NonFungibleToken,
      ExampleNFT,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [["0x0ae53cb6e3f42a79", types.Address]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });
});
