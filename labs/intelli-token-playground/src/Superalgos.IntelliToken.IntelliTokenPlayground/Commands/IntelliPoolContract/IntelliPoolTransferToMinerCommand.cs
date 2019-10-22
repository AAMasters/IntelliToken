﻿using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using Superalgos.IntelliToken.IntelliTokenDistribution;
using Superalgos.IntelliToken.IntelliTokenPlayground.Commands.ContractManagement;
using Superalgos.IntelliToken.IntelliTokenPlayground.Runtime;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Web3;

namespace Superalgos.IntelliToken.IntelliTokenPlayground.Commands.IntelliPoolContract
{
    public class IntelliPoolTransferToMinerCommand : EthInvokeTransactionalFunctionCommand
    {
        public string MinerAddress { get; set; }

        protected override async Task<TransactionReceipt> ExecuteAsync(RuntimeContext context, string contractAddress, Web3 web3)
        {
            var intellipool = new IntelliPool(contractAddress, web3, context.GasPriceProvider);

            return await intellipool.TransferToMinerAsync(context.ResolveContractReference(MinerAddress));
        }
    }
}