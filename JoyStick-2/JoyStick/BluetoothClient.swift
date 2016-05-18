//
//  BluetoothClient.swift
//  CoreBluetooth
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CoreBluetooth


class BluetoothClient: NSObject, CBPeripheralManagerDelegate
{
    //REQUIRED STUFF
	var peripheralManager      : CBPeripheralManager! // Coração do CoreBluetooth. gerencia os serviços no device frente a central.
	var transferCharacteristic : CBMutableCharacteristic? // Var de characteristic

    //DADOS
    var dataString: String        = "" // pode ser um dictionary ou qualquer outra coisa.
    var data                      = NSMutableData() // Guarda os dados preparados para enviar
	
    //FIM DA MENSAGEM
    var sendDataIndex : NSInteger = 0     // index do ponto em que a msg foi fatiada
	var sendingEOM                = false // flag para fim da mensagem


	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

    // SINGLETON
	static let sharedInstance = BluetoothClient() // O bluetooth pode ser um singleton porque um mesmo setup pode ter vários services e characteristics simultaneos.

	private override init() {
		super.init()
		self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil) // Seta a classe como o delegate do periférico.
	}
    
    
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: advertising API
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func stopAdvertising() {
		self.peripheralManager.stopAdvertising()
	}

	func startAdvertising() {
        //? Porque assim?
		self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [Bluetooth.Service]])
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBPeripheralManagerDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
    // sempre quando o estado do peripheral é mudado, ele prepara o serviço para advertising novamente
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
		
        //Verifica se o bluetooth está ligado
        guard peripheral.state == .PoweredOn else {
			return NSLog("peripherial is not powered on")
		}

        //Prepara a var de service
        let service             = CBMutableService(type: Bluetooth.Service, primary: true)
        
        //Prepara a var de caracteristic
		self.transferCharacteristic = CBMutableCharacteristic(type: Bluetooth.Characteristics, properties: .Notify, value: nil, permissions: .Readable)
		
        //Associa a caracteristic a um service
        service.characteristics = [self.transferCharacteristic!]

        //Adiciona o service no periférico
		self.peripheralManager.addService(service)
		NSLog("Service added.")

        //Inicia o advertising do service disponível no periférico.
		self.startAdvertising()
	}
	
    //Delegate chamado quando a central requer um dado (characteristic) de um serviço periférico.
	func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
		NSLog("Central subscribed to characteristic.")
		
        self.data			= self.dataString.dataUsingEncoding(NSUTF8StringEncoding)?.mutableCopy() as! NSMutableData //Converte o dataString em NSData.

		self.sendDataIndex	= 0 //Zera o index de fatiamento da metade
		self.sendingEOM		= false //Reseta a flag de fim de mensagem

		self.sendData() // Chama a função de enviar de fato os dados
	}

    //Esse callback aparece quando o PeripheralManager está pronto pra enviar o próximo pedaço de dados. Isso é para garantir que o pacote vai chegar na ordem em que eles foram enviados.
	func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        self.sendData() // Start sending novamente
        
	}

    //OK == 
	func sendData() {
		if self.sendingEOM { // se está chamando a End of Message, então...
            
            //update o valor da transferCharacheristic para o dado do fim da mensagem (e envia).
			let didSend = self.peripheralManager.updateValue(Bluetooth.EOMData, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil) // nil indica que são todas.
            
			if didSend {
				self.sendingEOM = false // se reseta a flag, o update tenha sido OK.
			}
			return
		}

        // caso a posição do sendDataIndex seja maior que o tamanho do NSData, então todos os dados já foram enviados, e nao há o que se fazer.
		if self.sendDataIndex >= self.data.length {
			return //no data left
		}
        
        // ... mas caso contrário...
		var didSend = true //seta-se didSend como flag
		
		while didSend { // enquanto == true
            
            // calcula-se o amount de dados a serem enviados.
			var amountToSend = self.data.length - self.sendDataIndex
			
            // caso seja mais que vinte, enviará 20 bytes. Caso tenha menos que 20 disponíveis, manda-se apenas os disponíveis.
			if amountToSend > 20 {
				amountToSend = 20
			}
            
            // Cria o Chunk, pedaço de dados a ser enviados a partir do index e o tamanho de bytes a ser enviados a partir desse index.
			let chunk = NSData(bytes: self.data.bytes+self.sendDataIndex, length: amountToSend)
            // Update do didSend com o novo chunk.
			didSend = self.peripheralManager.updateValue(chunk, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil)
			
			if !didSend { // caso tenha dado errado, retorna (e escapa o while)
				return
			}
            
            // caso contrário, printa o pedaço de dado enviado.
			let sentData = String(data: chunk, encoding: NSUTF8StringEncoding)

			//NSLog("\(sentData)")

            // ... e update o index do que já foi enviado
			self.sendDataIndex += amountToSend

            // verifica se é para chamar o fim da mensagem setando o sending EOM como true.
			if self.sendDataIndex >= self.data.length {
                // seta isso, e caso o envio falhe nós o enviaremos na próxima vez.
				self.sendingEOM = true
                //envia isso
				let didSend     = self.peripheralManager.updateValue(Bluetooth.EOMData, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil)
				if didSend {
                    //foi enviado, então deu tudo certo
					self.sendingEOM = false
                    NSLog("EOM SENT")
				}
				return
			}
		}
	}

}

